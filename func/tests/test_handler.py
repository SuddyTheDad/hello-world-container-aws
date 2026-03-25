import json

from handler import http_handler, scheduled_handler


def test_http_handler_returns_200():
    response = http_handler({}, None)
    assert response["statusCode"] == 200


def test_http_handler_content_type():
    response = http_handler({}, None)
    assert response["headers"]["Content-Type"] == "application/json"


def test_http_handler_body_has_message():
    response = http_handler({}, None)
    body = json.loads(response["body"])
    assert body["message"] == "Hello from Lambda!"


def test_http_handler_body_has_source():
    response = http_handler({}, None)
    body = json.loads(response["body"])
    assert body["source"] == "http-trigger"


def test_scheduled_handler_returns_ok():
    response = scheduled_handler({}, None)
    assert response["status"] == "ok"


def test_scheduled_handler_returns_message():
    response = scheduled_handler({}, None)
    assert "message" in response
