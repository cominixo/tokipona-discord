const { Plugin } = require('powercord/entities');

const { React, getModule, getModuleByDisplayName, i18n } = require('powercord/webpack');
const { inject, uninject } = require('powercord/injector');

const lang = require("./i18n");
const timestamps = require("./i18n/timestamps.json")

module.exports = class TokiPona extends Plugin {
  constructor () {
    super();

  }
  async startPlugin () {

    powercord.api.i18n.loadAllStrings(lang);
    // dumb hack, only a problem with the search text
    i18n.Messages.SEARCH = lang["en-US"].SEARCH;

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

    const test = await getModule(m => m.default?.displayName === "SearchBar");
    inject(
        "search-test",
        test,
        "default",
        (args, res) => {
            console.log("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n");
            console.log(res);
            return res;

        }
    );

  }

  pluginWillUnload () {
    uninject("translate-timestamp");
  }
};
