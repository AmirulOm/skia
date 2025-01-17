/*
 * Copyright 2016 Google Inc.
 *
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

#include "tools/skiaserve/urlhandlers/UrlHandler.h"

#include "microhttpd.h"
#include "src/core/SkStringUtils.h"
#include "tools/skiaserve/Request.h"
#include "tools/skiaserve/Response.h"

using namespace Response;

bool OpsHandler::canHandle(const char* method, const char* url) {
    const char* kBasePath = "/ops";
    return 0 == strncmp(url, kBasePath, strlen(kBasePath));
}

int OpsHandler::handle(Request* request, MHD_Connection* connection, const char* url,
                       const char* method, const char* upload_data, size_t* upload_data_size) {
    SkTArray<SkString> commands;
    SkStrSplit(url, "/", &commands);

    if (!request->hasPicture() || commands.size() > 1) {
        return MHD_NO;
    }

    // /ops
    if (0 == strcmp(method, MHD_HTTP_METHOD_GET)) {
        sk_sp<SkData> data(request->getJsonOpsTask());
        return SendData(connection, data.get(), "application/json");
    }

    return MHD_NO;
}
