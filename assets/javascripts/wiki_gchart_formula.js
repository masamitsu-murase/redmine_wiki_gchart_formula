
(function(){
    // base64 encoder (cheap implementation :-P)
    var BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    var encodeBase64 = function(data){
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

    // load binary data
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

    var loadBinaryData = function(url, callback){
        loadBinaryDataAsync(url, callback);
    };

    var loadGChartData = function(formula, callback){
        var GCHART_URL = "https://chart.googleapis.com/chart";
        return loadBinaryData(GCHART_URL + "?" + formula, callback);
    };

    var convertGChartUrlForPDF = function(url){
        // RMagick does not support transparent PNG,
        // so change background color to white.
        var url_for_pdf = url.replace(/chf=[^&]+/, "chf=bg%2Cs%2CFFFFFF");
        return url_for_pdf;
    };

    var loadAllGChartData = function(callback){
        var func = function(images, hash){
            if (images.size() == 0){
                callback(hash);
                return;
            }

            var img = images.shift();
            var raw_url = img.src;
            var url = convertGChartUrlForPDF(raw_url);
            var formula = raw_url.match(/(\?|&)chl=([^&]+)/)[2];
            loadBinaryData(url, function(data){
                hash[formula] = encodeBase64(data);
                func(images, hash);
            });
        };

        func($$("img." + gWikiGchartFormula.img_class), {});
    };

    var createHiddenInput = function(name, value){
        var hidden = document.createElement("input");
        hidden.setAttribute("type", "hidden");
        hidden.setAttribute("name", name);
        hidden.setAttribute("value", value);
        return hidden;
    };

    var load = function(){
        try{
            var form = $(gWikiGchartFormula.pdf_form_id);
            if (form){
                loadAllGChartData(function(hash){
                    for (var key in hash){
                        var hidden = createHiddenInput("gchart[][key]", key);
                        form.appendChild(hidden);
                        hidden = createHiddenInput("gchart[][png]", hash[key]);
                        form.appendChild(hidden);
                    }

                    var elem = $$("div#content p.other-formats")[0];
                    if (elem){
                        var span = document.createElement("span");
                        elem.appendChild(span);

                        var a = document.createElement("a");
                        a.setAttribute("href", "#");
                        a.innerHTML = "PDF (w/ Formula)";
                        a.observe("click", function(event){
                            form.submit();
                            event.preventDefault();
                            return false;
                        });
                        a.setAttribute("class", "wiki_gchart_formula_pdf");
                        span.appendChild(a);
                    }
                });
            }
        }catch(e){
        }
    };

    if (typeof(Prototype) !== "undefined" && typeof(gWikiGchartFormula) !== "undefined"){
        Event.observe(window, "load", load);
    }
})();

