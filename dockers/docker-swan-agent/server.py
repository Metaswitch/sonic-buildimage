"""
gRPC server to enable SWAN Agent to invoke swsscommon functions.
"""
import logging
from concurrent.futures import ThreadPoolExecutor

import subprocess
import grpc
import redis
from json import loads
from swsscommon import swsscommon

from redis_pb2 import FieldValuePair, FieldValuePairMap, RedisTableGetResponse, RedisTablePingResponse, RedisTableResponse, RedisTableWarmRestartResponse
from redis_pb2_grpc import RedisTableServicer, RedisTableServicer, add_RedisTableServicer_to_server

class RedisTableServer(RedisTableServicer):
    """
    Endpoint server for swss-common redis interaction gRPC service. 
    """
    def __init__(self, redis_socket_address, db_index):
        self.appl_db_connection = swsscommon.DBConnector(
            db_index,
            redis_socket_address,
            0
        )
        self.ps_tables = {
            "NEXT_HOP_GROUP_TABLE" : swsscommon.ProducerStateTable(
                self.appl_db_connection, "NEXT_HOP_GROUP_TABLE"
            ),
            "ROUTE_TABLE" : swsscommon.ProducerStateTable(
                self.appl_db_connection, "ROUTE_TABLE"
            ),
            "LABEL_ROUTE_TABLE" : swsscommon.ProducerStateTable(
                self.appl_db_connection, "LABEL_ROUTE_TABLE"
            ),
            "CLASS_BASED_NEXT_HOP_GROUP_TABLE" : swsscommon.ProducerStateTable(
                self.appl_db_connection,"CLASS_BASED_NEXT_HOP_GROUP_TABLE"
            ),
        }
        self.gt_tables = {
            "NEIGH_TABLE" : swsscommon.Table(
                self.appl_db_connection, "NEIGH_TABLE"
            ),
        }
        self.redis_client = redis.Redis(host="localhost", port=6379, db=0)
        
    def Set(self, request, context):
        """
        Set invokes the swss-common set command for creating/updating a table
        in APPL_DB and notifying orchagent that the update has occurred.
        """
        logging.info(f"Received set request for key {request.key}.")
        if request.table not in self.ps_tables:
            logging.error("Invalid table.")
            return RedisTableResponse(success=False)
        table = self.ps_tables[request.table]
        fvs = swsscommon.FieldValuePairs([(p.field, p.value) for p in request.fvPairs])
        table.set(request.key, fvs)
        logging.info(f"Successfully updated APPL_DB for key {request.key}.")
        resp = RedisTableResponse(success=True)
        return resp

    def Del(self, request, context):
        """
        Del invokes the swss-common delete command for deleting a table in
        APPL_DB and notifying orchagent that the update has occurred.
        """
        logging.info(f"Received del request for key {request.key}.")
        if request.table not in self.ps_tables:
            logging.error("Invalid table.")
            return RedisTableResponse(success=False)
        table = self.ps_tables[request.table]
        table.delete(request.key)
        logging.info(f"Successfully deleted {request.key} from APPL_DB.")
        resp = RedisTableResponse(success=True) 
        return resp

    def Get(self, request, context):
        """
        Get invokes the swss-common get command for retrieving field-value pairs
        associated with a particular key from redis. 
        """
        logging.info(f"Received get request for key {request.key}.")
        if request.table not in self.gt_tables:
            logging.error("Invalid table.")
            return RedisTableGetResponse(success=False)
        table = self.gt_tables[request.table]
        if request.key not in table.getKeys():
            logging.error(f"Key {request.key} was not found in table {request.table}.")
            return RedisTableGetResponse(success=False)
        success, fvs = table.get(request.key)
        if not success:
            logging.error(f"Failed to retrieve {request.table}:{request.key} from redis.")
            return RedisTableGetResponse(success=False)
        logging.info(f"Sucessfully retrieved {request.table}:{request.key} from redis.")
        resp = RedisTableGetResponse(
            success=True,
            fvPairs = [FieldValuePair(field=f, value=v) for f, v in fvs]
        )
        return resp

        
    def Ping(self, request, context):
        """
        Ping pings redis to assert that redis is still up. This currently acts
        as our metric for whether SONiC is healthy.
        """
        try:
            if self.redis_client.ping():
                # No DB issues, status is healthy.
                return RedisTablePingResponse(success=True)
        except:
            # DB issue detected, status is unhealthy.
            return RedisTablePingResponse(success=False)


    def get_swan_entries_from_appldb(self):
        """
        Discovers SWAN programmed keys in APPL_DB to enable SWAN to perform warm
        restart.
        """
        # Discover SWAN keys in APPL_DB.
        appl_db_contents = subprocess.run("sonic-db-dump -n APPL_DB -y".split() , capture_output=True)
        appl_db_json = loads(appl_db_contents.stdout)
        swan_keys = [key for key in appl_db_json if "swan_route" in appl_db_json[key]["value"]]
        # Remove any routes that orchagent hasn't processed.
        swan_keys = {k for k in swan_keys if not k.startswith("_")}
        swan_json = {key : FieldValuePairMap(fvPairs=value["value"]) for key, value in appl_db_json.items() if key in swan_keys}
        return swan_json
    
    def WarmRestart(self, request, context):
        """
        WarmRestart checks APPL_DB to see if there are any keys programmed by
        SWAN. If there are it reports the entries to SWAN Agent.
        """
        swan_data = self.get_swan_entries_from_appldb()
        if len(swan_data) == 0:
            # No SWAN entries in APPL_DB
            return RedisTableWarmRestartResponse(warmRestart=False)
        # SWAN entries found in APPL_DB.
        return RedisTableWarmRestartResponse(warmRestart=True, swanRedisData=swan_data)
        




if __name__ == '__main__':
    # Initialize the logger. These logs are sent to syslpg on SONiC.
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - SWAN gRPC Endpoint - %(levelname)s - %(message)s',
    )
    
    # Instantiate a grpc server.
    server = grpc.server(ThreadPoolExecutor())
    
    # Register our endpoint implementation with the gRPC server.
    add_RedisTableServicer_to_server(
        RedisTableServer(
            redis_socket_address="/run/redis/redis.sock",
            db_index=0),
            server,
    )
    
    # Start the server.
    port = 9999
    server.add_insecure_port(f'[::]:{port}')
    server.start()
    logging.info('server ready on port %r', port)
    server.wait_for_termination()
