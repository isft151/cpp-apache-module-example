#include <httpd.h>
#include <http_protocol.h>
#include <http_config.h>
#include <apr_uuid.h>


int HTTPRequestHandler(request_rec *reqrec)
{
	if ( !reqrec->handler || strcmp(reqrec->handler, "example") )
	{
		return DECLINED;
	}

	if ( reqrec->method_number != M_GET ) 
	{
		return HTTP_METHOD_NOT_ALLOWED;
	}

	apr_uuid_t uuid;
	apr_uuid_get(&uuid);

	char buff[APR_UUID_FORMATTED_LENGTH + 1];
	apr_uuid_format(&buff[0],&uuid);

	ap_set_content_type(reqrec, "text/html; charset=utf-8");
	ap_rprintf(reqrec, "C++ Apache Module: %s", buff );

	return OK;
}

void registerModuleHook(apr_pool_t *pool)
{
	ap_hook_handler(HTTPRequestHandler, NULL, NULL, APR_HOOK_LAST);
}

module example = 
{
    STANDARD20_MODULE_STUFF,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    registerModuleHook
};
