path   = require 'path'
fs     = require 'fs'
should = require 'should'
glob   = require 'glob'
rimraf = require 'rimraf'
Roots  = require 'roots'
W      = require 'when'
nodefn = require 'when/node/function'
_path  = path.join(__dirname, 'fixtures')
run = require('child_process').exec

# setup, teardown, and utils

should.file_exist = (path) ->
  fs.existsSync(path).should.be.ok

should.have_content = (path) ->
  fs.readFileSync(path).length.should.be.above(1)

should.contain = (path, content) ->
  fs.readFileSync(path, 'utf8').indexOf(content).should.not.equal(-1)

compile_fixture = (fixture_name, done) ->
  @path = path.join(_path, fixture_name)
  @public = path.join(@path, 'public')
  project = new Roots(@path)
  project.compile().on('error', done).on('done', done)

before (done) ->
  tasks = []
  for d in glob.sync("#{_path}/*/package.json")
    p = path.dirname(d)
    if fs.existsSync(path.join(p, 'node_modules')) then continue
    console.log "installing deps for #{d}"
    tasks.push nodefn.call(run, "cd #{p}; npm install")
  W.all(tasks, -> done())

after ->
  rimraf.sync(public_dir) for public_dir in glob.sync('test/fixtures/**/public')

# tests
describe 'basics', ->

  before (done) -> compile_fixture.call(@, 'yellr', done)

  it 'should upcase the content of upcased files', ->
    p = path.join(@public, 'LOUD.html')
    q = path.join(@public, 'quiet.html')
    should.file_exist(p)
    should.file_exist(q)
    should.contain(p, "LOUD NOISES")
    should.contain(q, "careless whispers")
