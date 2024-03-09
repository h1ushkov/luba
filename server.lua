local socket = require("socket")

local function loadPage(pagePath)
    local file = io.open(pagePath, "r")
    if file then
        local pageContent = file:read("*a")
        file:close()
        return pageContent
    end
    return nil
end


local function handleRequest(request)
    local path = request:match("GET (%S+) HTTP")
if path:match("/static/") then
    local staticFilePath = path:match("/static/(.*)")
    local staticContent = loadPage("static/" .. staticFilePath)

    if staticContent then
        return "200 OK", "text/css", staticContent
    else
        return "404 Not Found", "text/html", "<h1>404 Not Found</h1>"
    end
end

    if path == "/" then
        local pageList = "<html><head><link rel='stylesheet' type='text/css' href='/static/style.css'></head><body>"
        pageList = pageList .. "<h1>PAGES</h1><ul>"

        local files = io.popen('ls pages/'):lines()
        for fileName in files do
            local pageTitle = fileName:match("(.*)%.html")
            pageList = pageList .. string.format("<li><a href='/pages/%s'>%s</a></li>", pageTitle, pageTitle)
        end

        pageList = pageList .. "</ul></body></html>"

        return "200 OK", "text/html", pageList
    elseif path:match("/pages/") then
        local pageTitle = path:match("/pages/(.*)")

        local pagePath = "pages/" .. pageTitle .. ".html"
        local pageContent = loadPage(pagePath)

        if pageContent then
            return "200 OK", "text/html", pageContent
        else
            return "404 Not Found", "text/html", "<html><head><link rel='stylesheet' type='text/css' href='/style.css'></head><body><h1>404 Not Found</h1></body></html>"
        end
    else
        return "404 Not Found", "text/html", "<html><head><link rel='stylesheet' type='text/css' href='/style.css'></head><body><h1>404 Not Found</h1></body></html>"
    end
end

local function server()
    local server = socket.bind("127.0.0.1", 8080)

    print("Server is running at http://127.0.0.1:8080/")

    while true do
        local client = server:accept()

        if client then
            local request, err = client:receive()

            if request then
                local status, contentType, content = handleRequest(request)
                local response = string.format("HTTP/1.1 %s\r\nContent-Type: %s\r\n\r\n%s", status, contentType, content or "")
                client:send(response)
            end

            client:close()
        end
    end
end

server()
