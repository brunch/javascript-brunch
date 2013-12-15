describe('Plugin', function() {
  var plugin;

  beforeEach(function() {
    plugin = new Plugin({});
  });

  it('should be an object', function() {
    expect(plugin).to.be.ok;
  });

  it('should has #compile method', function() {
    expect(plugin.compile).to.be.an.instanceof(Function);
  });

  it('should compile and produce valid result', function(done) {
    var content = 'var a = 6;';
    var expected = 'var a = 6;';

    plugin.compile({data: content, path: 'file.js'}, function(error, result) {
      var data = result.data;
      expect(error).not.to.be.ok;
      expect(data).to.equal(expected);
      done();
    });
  });

  it('should validate JS syntax', function(done) {
    plugin.compile({data: 'var a =;', path: 'file.js'}, function(error, result) {
      expect(error).to.be.an.instanceof(Error);
      done();
    });
  })
});
