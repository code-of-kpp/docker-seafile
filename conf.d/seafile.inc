fastcgi_param   SCRIPT_FILENAME     $document_root$fastcgi_script_name;
fastcgi_param   PATH_INFO           $fastcgi_script_name;

fastcgi_param   SERVER_PROTOCOL     $server_protocol;
fastcgi_param   QUERY_STRING        $query_string;
fastcgi_param   REQUEST_METHOD      $request_method;
fastcgi_param   CONTENT_TYPE        $content_type;
fastcgi_param   CONTENT_LENGTH      $content_length;
fastcgi_param   SERVER_ADDR         $server_addr;
fastcgi_param   SERVER_PORT         $server_port;
fastcgi_param   SERVER_NAME         $server_name;
fastcgi_param   REMOTE_ADDR         $remote_addr;

fastcgi_param   HTTPS               $https if_not_empty;