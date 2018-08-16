moment = require 'moment'
{CompositeDisposable} = require 'atom'

module.exports = AtomTimestamp =
  config:
    timestampPrefix:
      order: 1
      title: 'Timestamp Prefix'
      description: 'Specify regular expression pattern for timestamp prefix.'
      type: 'string'
      default: 'Time-stamp:[ \\t]+["<]?'
    timestampSuffix:
      order: 2
      title: 'Timestamp Suffix'
      description: 'Specify regular expression pattern for timestamp suffix.'
      type: 'string'
      default: '[">]?$'
    timestampFormats:
      order: 3
      title: 'Timestamp Formats'
      description: 'Specify format-string for parsing/updating timestamp. Use [Moment.js format](http://momentjs.com/docs/#/displaying/format/). Time zone tokens (`z`, `zz`) and localized formats (`L`, `l`, ...) do not work.'
      type: 'array'
      default: [
        'MMM DD YYYY'
        'YYYY-MM-DD[T]HH:mm:ssZ'
        'YYYY-MM-DD HH:mm:ss'
        'YYYY-MM-DD'
        'YYYYMMDD'
      ]
      items:
        type: 'string'
    scopeSelector:
      order: 4
      title: 'Scope Selector'
      description: 'Specify regular expression pattern for scope name in syntax. Use `Editor: Log Cursor Scope` command to get scope names on current cursor.'
      type: 'string'
      default: '^comment\\b|plain\\.text'
    numberOfLines:
      order: 5
      title: 'Number of Lines'
      description: 'Specity number of lines from the beginning to search timestamp comments.'
      type: 'integer'
      default: 8
      minimum: 1
    updateOnSave:
      order: 6
      title: 'Auto-run update on save'
      type: 'boolean'
      default: true

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-timestamp:update-timestamp': =>
        if editor = atom.workspace.getActiveTextEditor()
          @updateTimestamp editor

    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      @subscriptions.add editor.getBuffer().onWillSave =>
        if atom.config.get 'atom-timestamp.updateOnSave'
          @updateTimestamp editor

  deactivate: ->
    @subscriptions.dispose()
    @subscriptions = null

  updateTimestamp: (editor) ->
    scanRange = [[0, 0], [atom.config.get('atom-timestamp.numberOfLines'), 0]]
    prefix = new RegExp atom.config.get('atom-timestamp.timestampPrefix'), 'g'
    suffix = new RegExp atom.config.get('atom-timestamp.timestampSuffix')
    scope = new RegExp atom.config.get 'atom-timestamp.scopeSelector'
    formats = atom.config.get 'atom-timestamp.timestampFormats'

    buffer = editor.getBuffer()
    buffer.transact =>
      buffer.backwardsScanInRange prefix, scanRange, ({range}) =>
        endPos = range.end
        lineText = buffer.lineForRow(endPos.row)
        return unless m = suffix.exec lineText.substring(endPos.column)
        str = m.input.substring(0, m.index)
        t = moment str, formats, true
        return unless t.isValid()

        scopeDescriptor = editor.scopeDescriptorForBufferPosition endPos
        return if scopeDescriptor.getScopesArray().every (s) -> !scope.test(s)

        rep = moment().utcOffset(str).format(t.creationData().format)
        buffer.setTextInRange [endPos, [endPos.row, endPos.column + m.index]], rep
