
(function(){
    // base64 encoder
    var encodeBase64 = function(data){
        var BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

        return data.inGroupsOf(3).map(function(item){
            var str = BASE64[item[0] >> 2];
            var num = (item[0] << 4) & 0x3F;
            if (item[1] === null){
                str += BASE64[num];
                return str + "==";
            }

            str += BASE64[num + (item[1] >> 4)];
            num = (item[1] << 2) & 0x3F;
            if (item[2] === null){
                str += BASE64[num];
                return str + "=";
            }

            str += BASE64[num + (item[2] >> 6)];
            num = (item[2] << 0) & 0x3F;
            str += BASE64[num];
            return str;
        }).join("");
    };

    // load binary
    var checkSuccess = function(status){
        return (!status || (200 <= status && status < 300) || status == 304 || status == 1223);
    };

    var convertResponseText = function(text){
        var length = text.length;
        var data = new Array(length);
        for (var i=0; i<length; i++){
            data[i] = (text.charCodeAt(i) & 0xFF);
        }
        return data;
    };

    var loadBinaryDataAsync = function(url, callback){
        var req = new XMLHttpRequest();
        req.open("GET", url, true);
        req.overrideMimeType("text/plain; charset=x-user-defined");
        req.onreadystatechange = function(){
            if (req.readyState == 4 && checkSuccess(req.status)){
                callback(convertResponseText(req.responseText));
            }
        };
        req.send(null);
    };

    var loadBinaryDataSync = function(url){
        var req = new XMLHttpRequest();
        req.open("GET", url, false);
        req.overrideMimeType("text/plain; charset=x-user-defined");
        req.send(null);

        var status = req.status;
        if (!checkSuccess(status)){
            return null;
        }
        return convertResponseText(req.responseText);
    };

    var loadBinaryData = function(url, callback){
        if (callback){
            loadBinaryDataAsync(url, callback);
        }else{
            return loadBinaryDataSync(url);
        }
    };

    var loadGChartData = function(formula, callback){
        var GCHART_URL = "https://chart.googleapis.com/chart";
        return loadBinaryData(GCHART_URL + "?" + formula, callback);
    };

    var parseUrl = function(url){
        var url_without_params = url.match(/^[^?#]+/)[0];
        var params = url.toQueryParams();
        return {
            url_without_params: url_without_params,
            params: params,
            raw_url: url
        };
    };

    var convertGChartUrlForPDF = function(url){
        var info = parseUrl(url);
        // RMagick does not support transparent PNG,
        // so change background color to white.
        info.params.chf = "bg,s,FFFFFF";
        return info.url_without_params + "?" + Object.toQueryString(info.params);
    };

    var loadAllGChartData = function(){
        var hash = {};
        $$("img." + gWikiGchartFormula.img_class).each(function(img){
            var info = parseUrl(img.src);
            var url = convertGChartUrlForPDF(info.raw_url);
            var data = loadBinaryData(url);
            hash[info.params.chl] = encodeBase64(data);
        });
        return hash;
    };

    var createHiddenInput = function(name, value){
        var hidden = document.createElement("input");
        hidden.setAttribute("type", "hidden");
        hidden.setAttribute("name", name);
        hidden.setAttribute("value", value);
        return hidden;
    };

    var getPDF = function(event, data){
        var f = document.createElement('form');
        f.style.display = 'none';
        event.originalTarget.parentNode.appendChild(f);
        f.method = 'POST';  // This should be GET, but some browsers do not support to send large data via GET.
        f.action = event.originalTarget.href;

        var token = $$("meta[name='csrf-token']")[0].readAttribute("content")
        var hidden = createHiddenInput("authenticity_token", token);
        f.appendChild(hidden);

        for (var key in data){
            hidden = createHiddenInput("gchart[][key]", key);
            f.appendChild(hidden);
            hidden = createHiddenInput("gchart[][png]", data[key]);
            f.appendChild(hidden);
        }
        f.submit();
    };

    var load = function(){
        var hash = loadAllGChartData();
        $("gchart_pdf").observe("click", function(event){
            getPDF(event, hash);
            event.preventDefault();
            return false;
        });
    };

    if (typeof(Prototype) !== "undefined" && typeof(gWikiGchartFormula) !== "undefined"){
        Event.observe(window, "load", load);
    }
})();

