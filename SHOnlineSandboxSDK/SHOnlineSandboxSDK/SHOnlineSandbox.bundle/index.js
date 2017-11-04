// define the item component
Vue.component('item', {
  template: '#item-template',
  props: {
    model: Object
  },
  data: function () {
    return {
      open: false
    }
  },
  computed: {
    isFolder: function () {
      return this.model.isf
    }
  },
  methods: {
    download: function(){

      var url = "/download.do?path=" + this.model.path;
      if (typeof (this.iframe) == "undefined")
      {
          var iframe = document.createElement("iframe");
          this.iframe = iframe;
          document.body.appendChild(iframe);
      }
      // alert(download_file.iframe);
      this.iframe.src = url;
      this.iframe.style.display = "none";
    },
    toggle: function () {
      if (this.isFolder) {
        var wantOpen = !this.open;
        if(wantOpen){
          if (!this.model.children || this.model.children.length == 0) {
            var _self = this;
            var path = '/sandbox.json?path=' + this.model.path;
            httpGet(path,function(data){
              var json = JSON.parse(data);

              if(json instanceof Array){
                if (!_self.children) {
                  Vue.set(_self.model, 'children', json);
                }
                _self.open = !_self.open;
              }
            },function(err){
              alert('sandbox-err:' + err)
            },function() {

            })
          }else {
            this.open = !this.open
          }
        }else {
          this.open = !this.open
        }
      }else {

      }
    },
    changeType: function () {
      if (!this.isFolder) {
        Vue.set(this.model, 'children', [])
        this.addChild()
        this.open = true
      }
    },
    addChild: function () {
      this.model.children.push({
        name: 'new stuff'
      })
    }
  }
})
