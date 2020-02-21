"""Handlers for the app's root, ``/``.
"""

__all__ = ["get_index"]

from aiohttp import web

from safirdemo.handlers import internal_routes


@internal_routes.get("/")
async def get_index(request) -> web.Response:
    """GET / (the app's internal root).

    By convention, this endpoint returns only the application's metadata.
    """
    metadata = request.config_dict["safir/metadata"]
    logger = request["logger"]
    logger.info("Got request on internal index route")
    return web.json_response(metadata)
