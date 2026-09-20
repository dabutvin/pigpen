/* Counting the ads, from the one place that can see them: this page.
 *
 * An ad for an iPhone game cannot be measured from inside the game without shipping
 * something — an SDK, a click identifier, a tracking prompt — and the game ships nothing of
 * the kind on purpose. So the count is taken here, on the page an ad lands on, in two halves
 * that between them reach as far as an install:
 *
 *   1. Google Ads is told when a visitor it sent taps the App Store button. That is the
 *      conversion a campaign can be pointed at, and Google sees it because the click that
 *      brought the visitor here is in the address it brought them to.
 *   2. The App Store button carries an App Store Connect campaign token, so Apple's own
 *      analytics count the downloads that follow — per campaign, on the Campaigns page under
 *      Acquisition, with nothing in the app to do it.
 *
 * Three blanks below, and all three are public by construction (they appear in every page
 * and every link that uses them). Empty means the page loads nothing from Google and rewrites
 * nothing: a fork, a deploy preview and a checkout all serve exactly the page they did — the
 * same bargain `TELEMETRYDECK_APP_ID` makes for the game. README: "Counting the ads".
 */
(function () {
  "use strict";

  // Google Ads → Goals → Conversions → the Google tag. Looks like "AW-1234567890".
  var GOOGLE_ADS_ID = "";

  // The conversion action for the App Store button, made in Google Ads as a website
  // conversion, "Click on a link". Its event snippet's send_to is "AW-…/<this>".
  var STORE_CLICK_LABEL = "";

  // App Store Connect → Analytics → Acquisition → Campaigns: the pt= in any link it makes.
  // One per developer account, the same for every campaign.
  var APP_STORE_PROVIDER_TOKEN = "";

  // Where consent has to be asked before an ad cookie is set: the EU, the rest of the EEA,
  // the UK and Switzerland. The page asks nobody, so there it stays denied and Google gets
  // only cookieless pings; everywhere else the cookie is set and a tap is counted in full.
  var CONSENT_REGIONS = [
    "AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IE",
    "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI", "ES", "SE",
    "IS", "LI", "NO", "GB", "CH"
  ];

  var STORE_HOST = "apps.apple.com";
  var arrived = new URLSearchParams(window.location.search);

  /* ---- Which campaign this visitor came from, in Apple's terms ---------------------- */

  // Apple allows up to thirty characters from a small alphabet; anything else is dropped
  // rather than escaped, since a token is a label to read off a chart, not data.
  function campaignToken() {
    var named = arrived.get("utm_campaign") || arrived.get("utm_source");
    var fromGoogle = arrived.has("gclid") || arrived.has("gbraid") || arrived.has("wbraid");
    var token = named || (fromGoogle ? "google-ads" : "website");
    return token.replace(/[^A-Za-z0-9 _.\-]/g, "").trim().slice(0, 30) || "website";
  }

  function storeLinks() {
    var all = document.querySelectorAll("a[href]");
    var found = [];
    for (var i = 0; i < all.length; i++) {
      if (all[i].hostname === STORE_HOST) found.push(all[i]);
    }
    return found;
  }

  // The button and the smart banner both point at the listing; both are told the campaign.
  function stampCampaign() {
    if (!APP_STORE_PROVIDER_TOKEN) return;
    var token = campaignToken();

    var links = storeLinks();
    for (var i = 0; i < links.length; i++) {
      var url = new URL(links[i].href);
      url.searchParams.set("pt", APP_STORE_PROVIDER_TOKEN);
      url.searchParams.set("ct", token);
      url.searchParams.set("mt", "8");
      links[i].href = url.toString();
    }

    var banner = document.querySelector('meta[name="apple-itunes-app"]');
    if (banner && banner.content.indexOf("affiliate-data=") === -1) {
      banner.content += ", affiliate-data=pt=" + APP_STORE_PROVIDER_TOKEN + "&ct=" + token;
    }
  }

  /* ---- Telling Google Ads about the tap ---------------------------------------------- */

  function gtag() {
    window.dataLayer.push(arguments);
  }

  // The tag, with consent said before it — the order is the whole point of consent mode.
  function loadGoogleTag() {
    if (!GOOGLE_ADS_ID) return;
    window.dataLayer = window.dataLayer || [];

    gtag("consent", "default", {
      ad_storage: "granted",
      ad_user_data: "granted",
      ad_personalization: "denied",
      analytics_storage: "denied"
    });
    gtag("consent", "default", {
      ad_storage: "denied",
      ad_user_data: "denied",
      ad_personalization: "denied",
      analytics_storage: "denied",
      region: CONSENT_REGIONS
    });

    var script = document.createElement("script");
    script.async = true;
    script.src = "https://www.googletagmanager.com/gtag/js?id=" + encodeURIComponent(GOOGLE_ADS_ID);
    document.head.appendChild(script);

    gtag("js", new Date());
    gtag("config", GOOGLE_ADS_ID);
  }

  // The tap is let through untouched — no preventDefault, no delayed navigation — so a
  // universal link still opens the App Store app and a cmd-click still opens a tab. The ping
  // goes by beacon, which outlives the page.
  function countStoreTaps() {
    if (!GOOGLE_ADS_ID || !STORE_CLICK_LABEL) return;
    var links = storeLinks();
    for (var i = 0; i < links.length; i++) {
      links[i].addEventListener("click", function () {
        gtag("event", "conversion", {
          send_to: GOOGLE_ADS_ID + "/" + STORE_CLICK_LABEL,
          transport_type: "beacon"
        });
      });
    }
  }

  loadGoogleTag();
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", function () {
      stampCampaign();
      countStoreTaps();
    });
  } else {
    stampCampaign();
    countStoreTaps();
  }
})();
