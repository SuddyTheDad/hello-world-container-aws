import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def http_handler(event, context):
    """HTTP trigger — equivalent to Azure HTTP Function."""
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": "Hello from Lambda!", "source": "http-trigger"}),
    }


def scheduled_handler(event, context):
    """Scheduled trigger — equivalent to Azure Timer Function."""
    logger.info("Scheduled function triggered: %s", event)
    return {"status": "ok", "message": "Scheduled run complete"}
