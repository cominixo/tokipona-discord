const { Plugin } = require('powercord/entities');

const { React, getModule, getModuleByDisplayName, i18n: { Messages } } = require('powercord/webpack');
const { inject, uninject } = require('powercord/injector');

const i18n = require("./i18n");
const timestamps = require("./i18n/timestamps.json")

module.exports = class TokiPona extends Plugin {
  async startPlugin () {
      
    powercord.api.i18n.loadAllStrings(i18n);
    const timestampModule = await getModule(m => m.default?.displayName === "MessageTimestamp");
    inject(
        "translate-timestamp",
        timestampModule,
        "default",
        (args, res) => {
            args[0].timestamp._locale = Object.assign(args[0].timestamp._locale, timestamps);
            return res;
        
        }
    );
  }

  pluginWillUnload () {
    uninject("translate-timestamp");
  }
};
