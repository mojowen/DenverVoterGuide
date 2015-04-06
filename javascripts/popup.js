(function() {
    var d = document,
        // Config
        config_elem = d.getElementById('popup_config'),
        frame_url = config_elem.getAttribute('data-url'),
        key = config_elem.getAttribute('data-key'),
        phone_name = config_elem.getAttribute('data-phone_name'),
        zip_name = config_elem.getAttribute('data-zip_name'),
        // Elements
        container = d.createElement('div'),
        mask = d.createElement('div'),
        frame = d.createElement('iframe'),
        closer = d.createElement('a'),
        // iFrame info
        post_back = document.location.toString(),
        params = ['action='+key,
                  'post_back='+post_back,
                  'phone_name='+phone_name,
                  'zip_name='+zip_name].join('&')

    // style
    mask.style.position = 'fixed'
    mask.style.top = '0px'
    mask.style.bottom = '0px'
    mask.style.left = '0px'
    mask.style.right = '0px'
    var inner = mask.cloneNode()
    mask.style.opacity = 0.6
    mask.style.background = 'black'

    inner.style.background = 'white'
    inner.style.margin = 'auto'
    inner.style.height = '80%'
    inner.style.width = '80%'
    inner.style.maxWidth = '500px'
    inner.style.maxHeight = '400px'
    inner.style.display = 'block'
    inner.style.borderRadius = '4px'
    inner.style.overflow = 'hidden'

    frame.style.width = '100%'
    frame.style.height = '100%'
    frame.style.overflow = 'hidden'
    frame.setAttribute('scrolling','no')

    closer.innerText = 'close'
    closer.href = '#'
    closer.style.position = "absolute"
    closer.style.top = "0"
    closer.style.right = "0"
    closer.style.padding = "4px 20px"
    closer.style.background = "#333"
    closer.style.textAlign = "center"
    closer.style.fontSize = "10px"
    closer.style.color = "white"

    // form frame
    frame.src = frame_url + '?' + params

    // bindings
    function close_popup(success) {
        success = success || false
        d.body.removeChild(container);
        try { ga('send', 'event', 'popup',
                 success ? 'close_success' : 'close_fail', key);
        } catch(e) { }
        document.cookie = key+"=set"

        return false;
    }

    mask.onclick = close_popup
    closer.onclick = close_popup

    try {
        window.addEventListener("message", function(e) {
            setTimeout( function() { close_popup(true); }, 500)
        })
    } catch(e) {}

    // append
    inner.appendChild(frame)
    inner.appendChild(closer)
    container.appendChild(mask)
    container.appendChild(inner)
    if( document.cookie.search(key) === -1 ) d.body.appendChild(container);
})()
