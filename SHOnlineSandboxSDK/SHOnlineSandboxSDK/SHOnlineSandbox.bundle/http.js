// ajax 对象
function ajaxObject() {
    var xmlHttp;
    try {
        // Firefox, Opera 8.0+, Safari
        xmlHttp = new XMLHttpRequest();
        }
    catch (e) {
        // Internet Explorer
        try {
                xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
            } catch (e) {
            try {
                xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
            } catch (e) {
                alert("您的浏览器不支持AJAX！");
                return false;
            }
        }
    }
    return xmlHttp;
}

// ajax get
function httpGet ( url , fnSucceed , fnFail , fnLoading ) {
    var ajax = ajaxObject();
    ajax.open("GET", url , true );
    // ajax.setRequestHeader( "Content-Type" , "application/x-www-form-urlencoded" );
    ajax.onreadystatechange = function () {

        if( ajax.readyState == 4 ) {
            if( ajax.status == 200 ) {
                fnSucceed( ajax.responseText );
            }
            else {
                fnFail( "HTTP请求错误！错误码："+ajax.status );
            }
        }
        else {
            fnLoading();
        }
    }
    ajax.send();
}
