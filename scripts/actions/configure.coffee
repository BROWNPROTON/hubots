require 'coffeescript/register'

classifier = require '../bot/classifier'
security = require '../lib/security'
{ msgVariables, stringElseRandomKey, sendMessages,
  loadConfigfile, getConfigFilePath } = require  '../lib/common'

class Configure
  constructor: (@interaction) ->

  process: (msg) =>
    if @interaction.role?
      if security.checkRole(msg, @interaction.role)
        @act(msg)
      else
        msg.sendWithNaturalDelay(
          "*Acces Denied* Action requires role #{@interaction.role}"
        )
    else
      @act(msg)

  setVariable: (msg) ->
    raw_message = msg.message.text.replace(msg.robot.name + ' ', '')
    configurationBlock = raw_message.split(' ')[-1..].toString()

    configKeyValue = configurationBlock.split('=')
    configKey = configKeyValue[0]
    configValue = configKeyValue[1]

    key = 'configure_' + configKey + '_' + msg.envelope.room
    msg.robot.brain.set(key, configValue)
    sendMessages(stringElseRandomKey(@interaction.answer), msg,
                  { key: configKey, value: configValue })
    return

  retrain: (msg) ->
    global.config = loadConfigfile getConfigFilePath()
    classifier.train()
    sendMessages(stringElseRandomKey(@interaction.answer), msg)
    return

  act: (msg) ->
    command = @interaction.command or 'setVariable'
    console.log command
    switch command
      when 'setVariable'
        @setVariable(msg)
      when 'train'
        @retrain(msg)
    return

module.exports = Configure
