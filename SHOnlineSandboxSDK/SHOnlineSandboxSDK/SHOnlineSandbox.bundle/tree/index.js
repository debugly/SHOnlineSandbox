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
    toggle: function () {
      if (this.isFolder) {
        var wantOpen = !this.open;
        if(wantOpen){
          if (!this.model.children || this.model.children.length == 0) {
            var _self = this;
            httpGet('http://localhost/subtree.json',function(data){
              var json = JSON.parse(data);
              if (!_self.children) {
                Vue.set(_self.model, 'children', json);
              }
              _self.open = !_self.open;
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
