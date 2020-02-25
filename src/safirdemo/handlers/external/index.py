"""Handlers for the app's external root, ``/<app-name>/``.
"""

__all__ = ["get_index"]

import structlog
from aiohttp import web

from safirdemo.handlers import routes


@routes.get("/")
async def get_index(request: web.Request) -> web.Response:
    """GET /<path>/ (the app's external root).

    By convention, the root of the external API includes a field called
    ``_metadata`` that provides the same metadata as the internal root
    endpoint. Here, the metadata is namespace so that you can customize the
    root of your API. For example, consider listing key API URLs.
    """
    metadata = request.config_dict["safir/metadata"]
    data = {"_metadata": metadata}
    logger = request["logger"]
    logger.info("Got request on index route")

    other_logger = structlog.get_logger(__name__)
    other_logger.info("Hello from other logger")

    return web.json_response(data)
