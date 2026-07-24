
import 'package:basement/utils.dart';
import 'package:flutter/material.dart';

///根据字符串名称返回ICONData
class IconUtil {

  static getIconData(String iconName) {
    if (iconName.isEmpty) {
      return Icons.info;
    }
    PrintUtil.printDebug('图标名称：' + iconName);
    iconName = iconName.replaceAll("fa fa-", "");
    iconName = iconName.replaceAll("-o", "");
    iconName = iconName.replaceAll("-", "");

    switch (iconName.toLowerCase()) {
      case "fivehundredpx":
        return Icons.info;

      case "accessibleicon":
        return Icons.info;

      case "accusoft":
        return Icons.info;

      case "acquisitionsincorporated":
        return Icons.info;

      case "ad":
        return Icons.info;

      case "addressbook":
        return Icons.info;

      case "solidaddressbook":
        return Icons.info;

      case "addresscard":
        return Icons.info;

      case "solidaddresscard":
        return Icons.info;

      case "adjust":
        return Icons.info;

      case "adn":
        return Icons.info;

      case "adversal":
        return Icons.info;

      case "affiliatetheme":
        return Icons.info;

      case "airfreshener":
        return Icons.info;

      case "algolia":
        return Icons.info;

      case "aligncenter":
        return Icons.info;

      case "alignjustify":
        return Icons.info;

      case "alignleft":
        return Icons.info;

      case "alignright":
        return Icons.info;

      case "alipay":
        return Icons.info;

      case "allergies":
        return Icons.info;

      case "amazon":
        return Icons.info;

      case "ambulance":
        return Icons.info;

      case "americansignLanguageinterpreting":
        return Icons.info;

      case "amilia":
        return Icons.info;

      case "anchor":
        return Icons.info;

      case "android":
        return Icons.info;

      case "angellist":
        return Icons.info;

      case "angledoubledown":
        return Icons.info;

      case "angledoubleleft":
        return Icons.info;

      case "angledoubleright":
        return Icons.info;

      case "angledoubleup":
        return Icons.info;

      case "angledown":
        return Icons.info;

      case "angleleft":
        return Icons.info;

      case "angleright":
        return Icons.info;

      case "angleup":
        return Icons.info;

      case "angry":
        return Icons.info;

      case "solidangry":
        return Icons.info;

      case "angrycreative":
        return Icons.info;

      case "angular":
        return Icons.info;

      case "ankh":
        return Icons.info;

      case "appstore":
        return Icons.info;

      case "appstoreios":
        return Icons.info;

      case "apper":
        return Icons.info;

      case "apple":
        return Icons.info;

      case "applealt":
        return Icons.info;

      case "applepay":
        return Icons.info;

      case "archive":
        return Icons.info;

      case "archway":
        return Icons.info;

      case "arrowaltcircledown":
        return Icons.info;

      case "solidarrowaltcircledown":
        return Icons.info;

      case "arrowaltcircleleft":
        return Icons.info;

      case "solidarrowaltcircleleft":
        return Icons.info;

      case "arrowaltcircleright":
        return Icons.info;

      case "solidarrowaltcircleright":
        return Icons.info;

      case "arrowaltcircleup":
        return Icons.info;

      case "solidarrowaltcircleup":
        return Icons.info;

      case "arrowcircledown":
        return Icons.info;

      case "arrowcircleleft":
        return Icons.info;

      case "arrowcircleright":
        return Icons.info;

      case "arrowcircleup":
        return Icons.info;

      case "arrowdown":
        return Icons.info;

      case "arrowleft":
        return Icons.info;

      case "arrowright":
        return Icons.info;

      case "arrowup":
        return Icons.info;

      case "arrowsalt":
        return Icons.info;

      case "arrowsalth":
        return Icons.info;

      case "arrowsaltv":
        return Icons.info;

      case "artstation":
        return Icons.info;

      case "assistivelisteningsystems":
        return Icons.info;

      case "asterisk":
        return Icons.info;

      case "asymmetrik":
        return Icons.info;

      case "at":
        return Icons.info;

      case "atlas":
        return Icons.info;

      case "atlassian":
        return Icons.info;

      case "atom":
        return Icons.info;

      case "audible":
        return Icons.info;

      case "audiodescription":
        return Icons.info;

      case "autoprefixer":
        return Icons.info;

      case "avianex":
        return Icons.info;

      case "aviato":
        return Icons.info;

      case "award":
        return Icons.info;

      case "aws":
        return Icons.info;

      case "baby":
        return Icons.info;

      case "babycarriage":
        return Icons.info;

      case "backspace":
        return Icons.info;

      case "backward":
        return Icons.info;

      case "bacon":
        return Icons.info;

      case "balancescale":
        return Icons.info;

      case "ban":
        return Icons.info;

      case "bandaid":
        return Icons.info;

      case "bandcamp":
        return Icons.info;

      case "barcode":
        return Icons.info;

      case "bars":
        return Icons.info;

      case "baseballball":
        return Icons.info;

      case "basketballball":
        return Icons.info;

      case "bath":
        return Icons.info;

      case "batteryempty":
        return Icons.info;

      case "batteryfull":
        return Icons.info;

      case "batteryhalf":
        return Icons.info;

      case "batteryquarter":
        return Icons.info;

      case "batterythreequarters":
        return Icons.info;

      case "bed":
        return Icons.info;

      case "beer":
        return Icons.info;

      case "behance":
        return Icons.info;

      case "behancesquare":
        return Icons.info;

      case "bell":
        return Icons.info;

      case "solidbell":
        return Icons.info;

      case "bellslash":
        return Icons.info;

      case "solidbellslash":
        return Icons.info;

      case "beziercurve":
        return Icons.info;

      case "bible":
        return Icons.info;

      case "bicycle":
        return Icons.info;

      case "bimobject":
        return Icons.info;

      case "binoculars":
        return Icons.info;

      case "biohazard":
        return Icons.info;

      case "birthdaycake":
        return Icons.info;

      case "bitbucket":
        return Icons.info;

      case "bitcoin":
        return Icons.info;

      case "bity":
        return Icons.info;

      case "blackTie":
        return Icons.info;

      case "blackberry":
        return Icons.info;

      case "blender":
        return Icons.info;

      case "blenderphone":
        return Icons.info;

      case "blind":
        return Icons.info;

      case "blog":
        return Icons.info;

      case "blogger":
        return Icons.info;

      case "bloggerb":
        return Icons.info;

      case "bluetooth":
        return Icons.info;

      case "bluetoothb":
        return Icons.info;

      case "bold":
        return Icons.info;

      case "bolt":
        return Icons.info;

      case "bomb":
        return Icons.info;

      case "bone":
        return Icons.info;

      case "bong":
        return Icons.info;

      case "book":
        return Icons.info;

      case "bookdead":
        return Icons.info;

      case "bookmedical":
        return Icons.info;

      case "bookopen":
        return Icons.info;

      case "bookreader":
        return Icons.info;

      case "bookmark":
        return Icons.info;

      case "solidbookmark":
        return Icons.info;

      case "bowlingball":
        return Icons.info;

      case "box":
        return Icons.info;

      case "boxopen":
        return Icons.info;

      case "boxes":
        return Icons.info;

      case "braille":
        return Icons.info;

      case "brain":
        return Icons.info;

      case "breadsslice":
        return Icons.info;

      case "briefcase":
        return Icons.info;

      case "btc":
        return Icons.info;

      case "bug":
        return Icons.info;

      case "briefcasemedical":
        return Icons.info;

      case "broadcasttower":
        return Icons.info;

      case "broom":
        return Icons.info;

      case "brush":
        return Icons.info;

      case "building":
        return Icons.info;

      case "solidbuilding":
        return Icons.info;

      case "bullhorn":
        return Icons.info;

      case "bullseye":
        return Icons.info;

      case "burn":
        return Icons.info;

      case "buromobelexperte":
        return Icons.info;

      case "bus":
        return Icons.info;

      case "busalt":
        return Icons.info;

      case "businesstime":
        return Icons.info;

      case "buysellads":
        return Icons.info;

      case "calculator":
        return Icons.info;

      case "calendar":
        return Icons.info;

      case "solidcalendar":
        return Icons.info;

      case "calendaralt":
        return Icons.info;

      case "solidcalendaralt":
        return Icons.info;

      case "calendarcheck":
        return Icons.info;

      case "solidcalendarcheck":
        return Icons.info;

      case "calendarday":
        return Icons.info;

      case "calendarminus":
        return Icons.info;

      case "solidcalendarminus":
        return Icons.info;

      case "calendarplus":
        return Icons.info;

      case "solidcalendarplus":
        return Icons.info;

      case "calendartimes":
        return Icons.info;

      case "solidcalendartimes":
        return Icons.info;

      case "calendarweek":
        return Icons.info;

      case "camera":
        return Icons.info;

      case "cameraretro":
        return Icons.info;

      case "campground":
        return Icons.info;

      case "canadianmapleleaf":
        return Icons.info;

      case "candycane":
        return Icons.info;

      case "cannabis":
        return Icons.info;

      case "capsules":
        return Icons.info;

      case "car":
        return Icons.info;

      case "caralt":
        return Icons.info;

      case "carbattery":
        return Icons.info;

      case "carcrash":
        return Icons.info;

      case "carside":
        return Icons.info;

      case "caretdown":
        return Icons.info;

      case "caretleft":
        return Icons.info;

      case "caretright":
        return Icons.info;

      case "caretsquaredown":
        return Icons.info;

      case "cashregister":
        return Icons.info;

      case "solidcaretsquaredown":
        return Icons.info;

      case "caretsquareleft":
        return Icons.info;

      case "solidcaretsquareleft":
        return Icons.info;

      case "caretsquareright":
        return Icons.info;

      case "solidcaretsquareright":
        return Icons.info;

      case "caretsquareup":
        return Icons.info;

      case "solidcaretsquareup":
        return Icons.info;

      case "caretup":
        return Icons.info;

      case "carrot":
        return Icons.info;

      case "cartrrowdown":
        return Icons.info;

      case "cartplus":
        return Icons.info;

      case "cashregister":
        return Icons.info;

      case "cat":
        return Icons.info;

      case "ccamazonpay":
        return Icons.info;

      case "ccamex":
        return Icons.info;

      case "ccapplepay":
        return Icons.info;

      case "ccdinersclub":
        return Icons.info;

      case "ccdiscover":
        return Icons.info;

      case "ccjcb":
        return Icons.info;

      case "ccmastercard":
        return Icons.info;

      case "ccpaypal":
        return Icons.info;

      case "ccstripe":
        return Icons.info;

      case "ccvisa":
        return Icons.info;

      case "centercode":
        return Icons.info;

      case "centos":
        return Icons.info;

      case "certificate":
        return Icons.info;

      case "chair":
        return Icons.info;

      case "chalkboard":
        return Icons.info;

      case "chalkboardteacher":
        return Icons.info;

      case "chargingstation":
        return Icons.info;

      case "chartarea":
        return Icons.info;

      case "chartbar":
        return Icons.info;

      case "solidchartbar":
        return Icons.info;

      case "chartline":
        return Icons.info;

      case "chartpie":
        return Icons.info;

      case "check":
        return Icons.info;

      case "checkcircle":
        return Icons.info;

      case "solidcheckcircle":
        return Icons.info;

      case "checkdouble":
        return Icons.info;

      case "checksquare":
        return Icons.info;

      case "cheese":
        return Icons.info;

      case "solidchecksquare":
        return Icons.info;

      case "chess":
        return Icons.info;

      case "chessbishop":
        return Icons.info;

      case "chessboard":
        return Icons.info;

      case "chessking":
        return Icons.info;

      case "chessknight":
        return Icons.info;

      case "chesspawn":
        return Icons.info;

      case "chessqueen":
        return Icons.info;

      case "chessrook":
        return Icons.info;

      case "chevroncircledown":
        return Icons.info;

      case "chevroncircleleft":
        return Icons.info;

      case "chevroncircleright":
        return Icons.info;

      case "chevroncircleup":
        return Icons.info;

      case "chevrondown":
        return Icons.info;

      case "chevronleft":
        return Icons.info;

      case "chevronright":
        return Icons.info;

      case "chevronup":
        return Icons.info;

      case "child":
        return Icons.info;

      case "chrome":
        return Icons.info;

      case "church":
        return Icons.info;

      case "circle":
        return Icons.info;

      case "solidcircle":
        return Icons.info;

      case "circlenotch":
        return Icons.info;

      case "city":
        return Icons.info;

      case "clinicmedical":
        return Icons.info;

      case "clipboard":
        return Icons.info;

      case "solidClipboard":
        return Icons.info;

      case "clipboardcheck":
        return Icons.info;

      case "clipboardlist":
        return Icons.info;

      case "clock":
        return Icons.info;

      case "solidclock":
        return Icons.info;

      case "clone":
        return Icons.info;

      case "solidclone":
        return Icons.info;

      case "closedcaptioning":
        return Icons.info;

      case "solidclosedcaptioning":
        return Icons.info;

      case "cloud":
        return Icons.info;

      case "clouddownloadalt":
        return Icons.info;

      case "cloudmeatball":
        return Icons.info;

      case "cloudmoon":
        return Icons.info;

      case "cloudmoonrain":
        return Icons.info;

      case "cloudrain":
        return Icons.info;

      case "cloudshowersheavy":
        return Icons.info;

      case "cloudsun":
        return Icons.info;

      case "cloudsunrain":
        return Icons.info;

      case "clouduploadalt":
        return Icons.info;

      case "cloudscale":
        return Icons.info;

      case "cloudsmith":
        return Icons.info;

      case "cloudversify":
        return Icons.info;

      case "cocktail":
        return Icons.info;

      case "code":
        return Icons.info;

      case "codebranch":
        return Icons.info;

      case "codepen":
        return Icons.info;

      case "codiepie":
        return Icons.info;

      case "coffee":
        return Icons.info;

      case "cog":
        return Icons.info;

      case "cogs":
        return Icons.info;

      case "coins":
        return Icons.info;

      case "columns":
        return Icons.info;

      case "comment":
        return Icons.info;

      case "solidcomment":
        return Icons.info;

      case "commentalt":
        return Icons.info;

      case "solidcommentalt":
        return Icons.info;

      case "commentdollar":
        return Icons.info;

      case "commentdots":
        return Icons.info;

      case "solidcommentdots":
        return Icons.info;

      case "commentmedical":
        return Icons.info;

      case "commentslash":
        return Icons.info;

      case "comments":
        return Icons.info;

      case "solidcomments":
        return Icons.info;

      case "commentsdollar":
        return Icons.info;

      case "compactdisc":
        return Icons.info;

      case "compass":
        return Icons.info;

      case "solidcompass":
        return Icons.info;

      case "compress":
        return Icons.info;

      case "compressArrowsalt":
        return Icons.info;

      case "conciergebell":
        return Icons.info;

      case "confluence":
        return Icons.info;

      case "connectdevelop":
        return Icons.info;

      case "contao":
        return Icons.info;

      case "cookie":
        return Icons.info;

      case "cookiebite":
        return Icons.info;

      case "copy":
        return Icons.info;

      case "solidcopy":
        return Icons.info;

      case "copyright":
        return Icons.info;

      case "solidcopyright":
        return Icons.info;

      case "couch":
        return Icons.info;

      case "cpanel":
        return Icons.info;

      case "creativecommons":
        return Icons.info;

      case "creativecommonsby":
        return Icons.info;

      case "creativecommonsnc":
        return Icons.info;

      case "creativecommonsnceu":
        return Icons.info;

      case "creativecommonsncjp":
        return Icons.info;

      case "creativecommonsnd":
        return Icons.info;

      case "creativecommonspd":
        return Icons.info;

      case "creativecommonsshare":
        return Icons.info;

      case "creativecommonszero":
        return Icons.info;

      case "creditcard":
        return Icons.info;

      case "solidcreditcard":
        return Icons.info;

      case "criticalrole":
        return Icons.info;

      case "crop":
        return Icons.info;

      case "cropalt":
        return Icons.info;

      case "cross":
        return Icons.info;

      case "crosshairs":
        return Icons.info;

      case "crow":
        return Icons.info;

      case "crown":
        return Icons.info;

      case "crutch":
        return Icons.info;

      case "css3":
        return Icons.info;

      case "css3alt":
        return Icons.info;

      case "cube":
        return Icons.info;

      case "cubes":
        return Icons.info;

      case "cut":
        return Icons.info;

      case "cuttlefish":
        return Icons.info;

      case "dandd":
        return Icons.info;

      case "dAnddbeyond":
        return Icons.info;

      case "dashcube":
        return Icons.info;

      case "database":
        return Icons.info;

      case "deaf":
        return Icons.info;

      case "delicious":
        return Icons.info;

      case "democrat":
        return Icons.info;

      case "deploydog":
        return Icons.info;

      case "deskpro":
        return Icons.info;

      case "desktop":
        return Icons.info;

      case "dev":
        return Icons.info;

      case "deviantart":
        return Icons.info;

      case "dharmachakra":
        return Icons.info;

      case "dhl":
        return Icons.info;

      case "diagnoses":
        return Icons.info;

      case "diaspora":
        return Icons.info;

      case "dice":
        return Icons.info;

      case "diced20":
        return Icons.info;

      case "diced6":
        return Icons.info;

      case "dicefive":
        return Icons.info;

      case "dicefour":
        return Icons.info;

      case "diceone":
        return Icons.info;

      case "dicexix":
        return Icons.info;

      case "dicethree":
        return Icons.info;

      case "dicetwo":
        return Icons.info;

      case "digg":
        return Icons.info;

      case "digitalocean":
        return Icons.info;

      case "digitaltachograph":
        return Icons.info;

      case "directions":
        return Icons.info;

      case "discord":
        return Icons.info;

      case "discourse":
        return Icons.info;

      case "divide":
        return Icons.info;

      case "dizzy":
        return Icons.info;

      case "soliddizzy":
        return Icons.info;

      case "dna":
        return Icons.info;

      case "dochub":
        return Icons.info;

      case "docker":
        return Icons.info;

      case "dog":
        return Icons.info;

      case "dollarsign":
        return Icons.info;

      case "dolly":
        return Icons.info;

      case "dollyflatbed":
        return Icons.info;

      case "donate":
        return Icons.info;

      case "doorclosed":
        return Icons.info;

      case "dooropen":
        return Icons.info;

      case "dotcircle":
        return Icons.info;

      case "soliddotcircle":
        return Icons.info;

      case "dove":
        return Icons.info;

      case "download":
        return Icons.info;

      case "draft2digital":
        return Icons.info;

      case "draftingcompass":
        return Icons.info;

      case "dragon":
        return Icons.info;

      case "drawpolygon":
        return Icons.info;

      case "dribbble":
        return Icons.info;

      case "dribbblesquare":
        return Icons.info;

      case "dropbox":
        return Icons.info;

      case "drum":
        return Icons.info;

      case "drumsteelpan":
        return Icons.info;

      case "drumstickbite":
        return Icons.info;

      case "drupal":
        return Icons.info;

      case "dumbbell":
        return Icons.info;

      case "dumpster":
        return Icons.info;

      case "dumpsterfire":
        return Icons.info;

      case "dungeon":
        return Icons.info;

      case "dyalog":
        return Icons.info;

      case "earlybirds":
        return Icons.info;

      case "ebay":
        return Icons.info;

      case "edge":
        return Icons.info;

      case "edit":
        return Icons.info;

      case "solidedit":
        return Icons.info;

      case "egg":
        return Icons.info;

      case "eject":
        return Icons.info;

      case "elementor":
        return Icons.info;

      case "ellipsish":
        return Icons.info;

      case "ellipsisv":
        return Icons.info;

      case "ello":
        return Icons.info;

      case "ember":
        return Icons.info;

      case "empire":
        return Icons.info;

      case "envelope":
        return Icons.info;

      case "solidenvelope":
        return Icons.info;

      case "envelopeopen":
        return Icons.info;

      case "solidenvelopeopen":
        return Icons.info;

      case "envelopeopentext":
        return Icons.info;

      case "envelopesquare":
        return Icons.info;

      case "envira":
        return Icons.info;

      case "equals":
        return Icons.info;

      case "eraser":
        return Icons.info;

      case "erlang":
        return Icons.info;

      case "ethereum":
        return Icons.info;

      case "ethernet":
        return Icons.info;

      case "etsy":
        return Icons.info;

      case "eurosign":
        return Icons.info;

      case "exchangealt":
        return Icons.info;

      case "exclamation":
        return Icons.info;

      case "exclamationcircle":
        return Icons.info;

      case "exclamationtriangle":
        return Icons.info;

      case "expand":
        return Icons.info;

      case "expandarrowsalt":
        return Icons.info;

      case "expeditedssl":
        return Icons.info;

      case "externallinkalt":
        return Icons.info;

      case "externalLinksquarealt":
        return Icons.info;

      case "eye":
        return Icons.info;

      case "solideye":
        return Icons.info;

      case "eyedropper":
        return Icons.info;

      case "eyeslash":
        return Icons.info;

      case "solideyeslash":
        return Icons.info;

      case "facebook":
        return Icons.info;

      case "facebookf":
        return Icons.info;

      case "facebookmessenger":
        return Icons.message_sharp;

      case "facebooksquare":
        return Icons.info;

      case "fantasyflightgames":
        return Icons.info;

      case "fastbackward":
        return Icons.info;

      case "fastforward":
        return Icons.info;

      case "fax":
        return Icons.info;

      case "feather":
        return Icons.info;

      case "featheralt":
        return Icons.info;

      case "fedex":
        return Icons.info;

      case "fedora":
        return Icons.info;

      case "female":
        return Icons.info;

      case "fighterjet":
        return Icons.info;

      case "figma":
        return Icons.info;

      case "file":
        return Icons.info;

      case "solidfile":
        return Icons.info;

      case "filealt":
        return Icons.info;

      case "solidfilealt":
        return Icons.info;

      case "filearchive":
        return Icons.info;
      case "filephoto"  :

      case "solidfilearchive":
        return Icons.info;

      case "fileaudio":
        return Icons.info;

      case "solidfileaudio":
        return Icons.info;

      case "filecode":
        return Icons.info;
      case "filetext":
        return Icons.info;

      case "solidfilecode":
        return Icons.info;

      case "filecontract":
        return Icons.info;

      case "filecsv":
        return Icons.info;

      case "filedownload":
        return Icons.info;

      case "fileexcel":
        return Icons.info;

      case "solidfileexcel":
        return Icons.info;

      case "fileexport":
        return Icons.info;

      case "fileimage":
        return Icons.info;

      case "solidfileimage":
        return Icons.info;

      case "fileimport":
        return Icons.info;

      case "fileinvoice":
        return Icons.info;

      case "fileinvoicedollar":
        return Icons.info;

      case "filemedical":
        return Icons.info;

      case "filemedicalalt":
        return Icons.info;

      case "filepdf":
        return Icons.info;

      case "solidfilepdf":
        return Icons.info;

      case "filepowerpoint":
        return Icons.info;

      case "solidfilepowerpoint":
        return Icons.info;

      case "fileprescription":
        return Icons.info;

      case "filesignature":
        return Icons.info;

      case "fileupload":
        return Icons.info;

      case "filevideo":
        return Icons.info;

      case "solidfilevideo":
        return Icons.info;

      case "fileword":
        return Icons.info;

      case "solidfileword":
        return Icons.info;

      case "fill":
        return Icons.info;

      case "filldrip":
        return Icons.info;

      case "film":
        return Icons.info;

      case "filter":
        return Icons.info;

      case "fingerprint":
        return Icons.info;

      case "fire":
        return Icons.info;

      case "firealt":
        return Icons.info;

      case "fireextinguisher":
        return Icons.info;

      case "firefox":
        return Icons.info;

      case "firstaid":
        return Icons.info;

      case "firstorder":
        return Icons.info;

      case "firstorderalt":
        return Icons.info;

      case "firstdraft":
        return Icons.info;

      case "fish":
        return Icons.info;

      case "fistraised":
        return Icons.info;

      case "flag":
        return Icons.info;

      case "solidflag":
        return Icons.info;

      case "flagcheckered":
        return Icons.info;

      case "flagusa":
        return Icons.info;

      case "flask":
        return Icons.info;

      case "flickr":
        return Icons.info;

      case "flipboard":
        return Icons.info;

      case "flushed":
        return Icons.info;

      case "solidflushed":
        return Icons.info;

      case "fly":
        return Icons.info;

      case "folder":
        return Icons.info;

      case "solidfolder":
        return Icons.info;

      case "folderminus":
        return Icons.info;

      case "folderopen":
        return Icons.info;

      case "solidfolderopen":
        return Icons.info;

      case "folderplus":
        return Icons.info;

      case "font":
        return Icons.info;

      case "fontawesome":
        return Icons.info;

      case "fontawesomealt":
        return Icons.info;

      case "fontawesomeflag":
        return Icons.info;

      case "fonticons":
        return Icons.info;

      case "fonticonsfi":
        return Icons.info;

      case "footballball":
        return Icons.info;

      case "fortawesome":
        return Icons.info;

      case "fortawesomealt":
        return Icons.info;

      case "forumbee":
        return Icons.info;

      case "forward":
        return Icons.info;

      case "foursquare":
        return Icons.info;

      case "freecodecamp":
        return Icons.info;

      case "freebsd":
        return Icons.info;

      case "frog":
        return Icons.info;

      case "frown":
        return Icons.info;

      case "solidfrown":
        return Icons.info;

      case "frownopen":
        return Icons.info;

      case "solidfrownopen":
        return Icons.info;

      case "fulcrum":
        return Icons.info;

      case "funneldollar":
        return Icons.info;

      case "futbol":
        return Icons.info;

      case "solidfutbol":
        return Icons.info;

      case "galacticrepublic":
        return Icons.info;

      case "galacticsenate":
        return Icons.info;

      case "gamepad":
        return Icons.info;

      case "gaspump":
        return Icons.info;

      case "gavel":
        return Icons.info;

      case "gem":
        return Icons.info;

      case "solidgem":
        return Icons.info;

      case "genderless":
        return Icons.info;

      case "getpocket":
        return Icons.info;

      case "gg":
        return Icons.info;

      case "ggcircle":
        return Icons.info;

      case "ghost":
        return Icons.info;

      case "gift":
        return Icons.info;

      case "gifts":
        return Icons.info;

      case "git":
        return Icons.info;

      case "gitsquare":
        return Icons.info;

      case "github":
        return Icons.info;

      case "githubalt":
        return Icons.info;

      case "githubsquare":
        return Icons.info;

      case "gitkraken":
        return Icons.info;

      case "gitlab":
        return Icons.info;

      case "gitter":
        return Icons.info;

      case "glasscheers":
        return Icons.info;

      case "glassmartini":
        return Icons.info;

      case "glassmartinialt":
        return Icons.info;

      case "glasswhiskey":
        return Icons.info;

      case "glasses":
        return Icons.info;

      case "glide":
        return Icons.info;

      case "glideg":
        return Icons.info;

      case "globe":
        return Icons.info;

      case "globeafrica":
        return Icons.info;

      case "globeamericas":
        return Icons.info;

      case "globeasia":
        return Icons.info;

      case "globeeurope":
        return Icons.info;

      case "gofore":
        return Icons.info;

      case "golfball":
        return Icons.info;

      case "goodreads":
        return Icons.info;

      case "goodreadsg":
        return Icons.info;

      case "google":
        return Icons.info;

      case "googledrive":
        return Icons.info;

      case "googleplay":
        return Icons.info;

      case "googleplus":
        return Icons.info;

      case "googleplusg":
        return Icons.info;

      case "googleplussquare":
        return Icons.info;

      case "googlewallet":
        return Icons.info;

      case "gopuram":
        return Icons.info;

      case "graduationcap":
        return Icons.info;

      case "gratipay":
        return Icons.info;

      case "grav":
        return Icons.info;

      case "greaterthan":
        return Icons.info;

      case "greaterthanequal":
        return Icons.info;

      case "grimace":
        return Icons.info;

      case "solidgrimace":
        return Icons.info;

      case "grin":
        return Icons.info;

      case "solidgrin":
        return Icons.info;

      case "grinalt":
        return Icons.info;

      case "solidgrinalt":
        return Icons.info;

      case "grinbeam":
        return Icons.info;

      case "solidgrinbeam":
        return Icons.info;

      case "grinbeamsweat":
        return Icons.info;

      case "solidgrinbeamsweat":
        return Icons.info;

      case "grinhearts":
        return Icons.info;

      case "solidgrinhearts":
        return Icons.info;

      case "grinsquint":
        return Icons.info;

      case "solidgrinsquint":
        return Icons.info;

      case "grinsquinttears":
        return Icons.info;

      case "solidgrinsquinttears":
        return Icons.info;

      case "grinstars":
        return Icons.info;

      case "solidgrinstars":
        return Icons.info;

      case "grintears":
        return Icons.info;

      case "solidgrintears":
        return Icons.info;

      case "grintongue":
        return Icons.info;

      case "solidgrintongue":
        return Icons.info;

      case "grintonguesquint":
        return Icons.info;

      case "solidgrintonguesquint":
        return Icons.info;

      case "grintonguewink":
        return Icons.info;

      case "solidgrintonguewink":
        return Icons.info;

      case "grinwink":
        return Icons.info;

      case "solidgrinwink":
        return Icons.info;

      case "griphorizontal":
        return Icons.info;

      case "griplines":
        return Icons.info;

      case "griplinesvertical":
        return Icons.info;

      case "gripvertical":
        return Icons.info;

      case "gripfire":
        return Icons.info;

      case "grunt":
        return Icons.info;

      case "guitar":
        return Icons.info;

      case "gulp":
        return Icons.info;

      case "hsquare":
        return Icons.info;

      case "hackernews":
        return Icons.info;

      case "hackernewssquare":
        return Icons.info;

      case "hackerrank":
        return Icons.info;

      case "hammer":
        return Icons.info;

      case "handholdingheart":
        return Icons.info;

      case "hamburger":
        return Icons.info;

      case "hamsa":
        return Icons.info;

      case "handholding":
        return Icons.info;

      case "handholdingusd":
        return Icons.info;

      case "handlizard":
        return Icons.info;

      case "solidhandlizard":
        return Icons.info;

      case "handmiddlefinger":
        return Icons.info;

      case "handpaper":
        return Icons.info;

      case "solidhandpaper":
        return Icons.info;

      case "handpeace":
        return Icons.info;

      case "solidhandpeace":
        return Icons.info;

      case "handpointdown":
        return Icons.info;

      case "solidhandpointdown":
        return Icons.info;

      case "handpointleft":
        return Icons.info;

      case "solidhandpointleft":
        return Icons.info;

      case "handpointright":
        return Icons.info;

      case "solidhandpointright":
        return Icons.info;

      case "handpointup":
        return Icons.info;

      case "solidhandpointup":
        return Icons.info;

      case "handpointer":
        return Icons.info;

      case "solidhandpointer":
        return Icons.info;

      case "handrock":
        return Icons.info;

      case "solidhandrock":
        return Icons.info;

      case "handscissors":
        return Icons.info;

      case "solidhandscissors":
        return Icons.info;

      case "handspock":
        return Icons.info;

      case "solidhandspock":
        return Icons.info;

      case "hands":
        return Icons.info;

      case "handshelping":
        return Icons.info;

      case "handshake":
        return Icons.info;

      case "solidhandshake":
        return Icons.info;

      case "hanukiah":
        return Icons.info;

      case "hardhat":
        return Icons.info;

      case "hashtag":
        return Icons.info;

      case "hatwizard":
        return Icons.info;

      case "hdd":
        return Icons.info;

      case "solidhdd":
        return Icons.info;

      case "heading":
        return Icons.info;

      case "headphones":
        return Icons.info;

      case "headphonesalt":
        return Icons.info;

      case "headset":
        return Icons.info;

      case "heart":
        return Icons.info;

      case "solidheart":
        return Icons.info;

      case "heartbroken":
        return Icons.info;

      case "heartbeat":
        return Icons.info;

      case "highlighter":
        return Icons.info;

      case "helicopter":
        return Icons.info;

      case "hiking":
        return Icons.info;

      case "hippo":
        return Icons.info;

      case "hips":
        return Icons.info;

      case "hireahelper":
        return Icons.info;

      case "history":
        return Icons.info;

      case "hockeypuck":
        return Icons.info;

      case "hollyberry":
        return Icons.info;

      case "home":
        return Icons.info;

      case "hooli":
        return Icons.info;

      case "hornbill":
        return Icons.info;

      case "horse":
        return Icons.info;

      case "horsehead":
        return Icons.info;

      case "hospital":
        return Icons.info;

      case "solidhospital":
        return Icons.info;

      case "hospitalalt":
        return Icons.info;

      case "hotdog":
        return Icons.info;

      case "hotel":
        return Icons.info;

      case "hotjar":
        return Icons.info;

      case "hospitalsymbol":
        return Icons.info;

      case "hotTub":
        return Icons.info;

      case "hourglass":
        return Icons.info;

      case "housedamage":
        return Icons.info;

      case "solidhourglass":
        return Icons.info;

      case "hourglassend":
        return Icons.info;

      case "hourglasshalf":
        return Icons.info;

      case "hourglassstart":
        return Icons.info;

      case "houzz":
        return Icons.info;

      case "idbadge":
        return Icons.info;

      case "icicles":
        return Icons.info;

      case "icecream":
        return Icons.info;

      case "icursor":
        return Icons.info;

      case "hubspot":
        return Icons.info;

      case "html5":
        return Icons.info;

      case "hryvnia":
        return Icons.info;

      case "solidIdbadge":
        return Icons.info;

      case "idcard":
        return Icons.info;

      case "solididcard":
        return Icons.info;

      case "idcardalt":
        return Icons.info;

      case "image":
        return Icons.info;

      case "igloo":
        return Icons.info;

      case "solidimage":
        return Icons.info;

      case "images":
        return Icons.info;

      case "solidimages":
        return Icons.info;

      case "imdb":
        return Icons.info;

      case "jedi":
        return Icons.info;

      case "infocircle":
        return Icons.info;

      case "info":
        return Icons.info;

      case "infinity":
        return Icons.info;

      case "industry":
        return Icons.info;

      case "indent":
        return Icons.info;

      case "inbox":
        return Icons.info;

      case "instagram":
        return Icons.info;

      case "intercom":
        return Icons.info;

      case "internetexplorer":
        return Icons.info;

      case "invision":
        return Icons.info;

      case "ioxhost":
        return Icons.info;

      case "italic":
        return Icons.info;

      case "itunes":
        return Icons.info;

      case "itunesnote":
        return Icons.info;

      case "java":
        return Icons.info;

      case "jediorder":
        return Icons.info;

      case "jenkins":
        return Icons.info;

      case "jira":
        return Icons.info;

      case "joget":
        return Icons.info;

      case "joint":
        return Icons.info;

      case "joomla":
        return Icons.info;

      case "journalwhills":
        return Icons.info;

      case "js":
        return Icons.info;

      case "jssquare":
        return Icons.info;

      case "jsfiddle":
        return Icons.info;

      case "kaaba":
        return Icons.info;

      case "kaggle":
        return Icons.info;

      case "key":
        return Icons.info;

      case "keybase":
        return Icons.info;

      case "keyboard":
        return Icons.info;

      case "solidkeyboard":
        return Icons.info;

      case "keycdn":
        return Icons.info;

      case "khanda":
        return Icons.info;

      case "kickstarter":
        return Icons.info;

      case "kickstarterk":
        return Icons.info;

      case "kiss":
        return Icons.info;

      case "solidkiss":
        return Icons.info;

      case "kissbeam":
        return Icons.info;

      case "solidkissbeam":
        return Icons.info;

      case "kisswinkheart":
        return Icons.info;

      case "solidkisswinkheart":
        return Icons.info;

      case "kiwibird":
        return Icons.info;

      case "korvue":
        return Icons.info;

      case "landmark":
        return Icons.info;

      case "language":
        return Icons.info;

      case "laptop":
        return Icons.info;

      case "laptopcode":
        return Icons.info;

      case "laptopmedical":
        return Icons.info;

      case "laravel":
        return Icons.info;

      case "lastfm":
        return Icons.info;

      case "lastfmsquare":
        return Icons.info;

      case "laugh":
        return Icons.info;

      case "solidlaugh":
        return Icons.info;

      case "laughbeam":
        return Icons.info;

      case "solidlaughbeam":
        return Icons.info;

      case "laughsquint":
        return Icons.info;

      case "solidlaughsquint":
        return Icons.info;

      case "laughwink":
        return Icons.info;

      case "solidlaughwink":
        return Icons.info;

      case "layergroup":
        return Icons.info;

      case "leaf":
        return Icons.info;

      case "leanpub":
        return Icons.info;

      case "lemon":
        return Icons.info;

      case "solidlemon":
        return Icons.info;

      case "lifering":
        return Icons.info;

      case "levelupalt":
        return Icons.info;

      case "leveldownalt":
        return Icons.info;

      case "lessthanequal":
        return Icons.info;

      case "lessthan":
        return Icons.info;

      case "less":
        return Icons.info;

      case "solidlifering":
        return Icons.info;

      case "lightbulb":
        return Icons.info;

      case "solidlightbulb":
        return Icons.info;

      case "line":
        return Icons.info;

      case "link":
        return Icons.info;

      case "linkedin":
        return Icons.info;

      case "linkedinin":
        return Icons.info;

      case "linode":
        return Icons.info;

      case "linux":
        return Icons.info;

      case "lirasign":
        return Icons.info;

      case "list":
        return Icons.info;

      case "listalt":
        return Icons.info;

      case "solidlistalt":
        return Icons.info;

      case "listOl":
        return Icons.info;

      case "listul":
        return Icons.info;

      case "locationarrow":
        return Icons.info;

      case "lock":
        return Icons.info;

      case "lockopen":
        return Icons.info;

      case "longarrowaltdown":
        return Icons.info;

      case "longarrowaltleft":
        return Icons.info;

      case "longarrowaltright":
        return Icons.info;

      case "longarrowaltup":
        return Icons.info;

      case "lowvision":
        return Icons.info;

      case "luggagecart":
        return Icons.info;

      case "lyft":
        return Icons.info;

      case "magento":
        return Icons.info;

      case "magic":
        return Icons.info;

      case "magnet":
        return Icons.info;

      case "mailbulk":
        return Icons.info;

      case "mandalorian":
        return Icons.info;

      case "male":
        return Icons.info;

      case "mailchimp":
        return Icons.info;

      case "mapmarkeralt":
        return Icons.info;

      case "mapmarkedalt":
        return Icons.info;

      case "mapmarker":
        return Icons.info;

      case "mapmarked":
        return Icons.info;

      case "solidmap":
        return Icons.info;

      case "map":
        return Icons.info;

      case "mars":
        return Icons.info;

      case "marker":
        return Icons.info;

      case "markdown":
        return Icons.info;

      case "mapsigns":
        return Icons.info;

      case "mappin":
        return Icons.info;

      case "mask":
        return Icons.info;

      case "marsstrokev":
        return Icons.info;

      case "marsstrokeh":
        return Icons.info;

      case "marsstroke":
        return Icons.info;

      case "marsdouble":
        return Icons.info;

      case "medapps":
        return Icons.info;

      case "medal":
        return Icons.info;

      case "maxcdn":
        return Icons.info;

      case "mastodon":
        return Icons.info;

      case "medkit":
        return Icons.info;

      case "mediumm":
        return Icons.info;

      case "medium":
        return Icons.info;

      case "meetup":
        return Icons.info;

      case "meh":
        return Icons.info;

      case "megaport":
        return Icons.info;

      case "medrt":
        return Icons.info;

      case "mehrollingeyes":
        return Icons.info;

      case "solidmehblank":
        return Icons.info;

      case "mehblank":
        return Icons.info;

      case "solidmeh":
        return Icons.info;

      case "solidmehrollingeyes":
        return Icons.info;

      case "memory":
        return Icons.info;

      case "mendeley":
        return Icons.info;

      case "menorah":
        return Icons.info;

      case "mercury":
        return Icons.info;

      case " meteor":
        return Icons.info;

      case "microchip":
        return Icons.info;

      case "microphone":
        return Icons.info;

      case "microphonealt":
        return Icons.info;

      case "microsoft":
        return Icons.info;

      case "microscope":
        return Icons.info;

      case "microphoneslash":
        return Icons.info;

      case "microphonealtslash":
        return Icons.info;

      case "solidminussquare":
        return Icons.info;

      case "mitten":
        return Icons.info;

      case "minussquare":
        return Icons.info;

      case "minuscircle":
        return Icons.info;

      case "minus":
        return Icons.info;

      case "mix":
        return Icons.info;

      case "mixcloud":
        return Icons.info;

      case "mizuni":
        return Icons.info;

      case "mobile":
        return Icons.info;

      case "mobilealt":
        return Icons.info;

      case "modx":
        return Icons.info;

      case "monero":
        return Icons.info;

      case "moneybill":
        return Icons.info;

      case "moneybillalt":
        return Icons.info;

      case "solidMoneybillalt":
        return Icons.info;

      case "moneybillwave":
        return Icons.info;

      case "moneybillwavealt":
        return Icons.info;

      case "moneycheck":
        return Icons.info;

      case "mosque":
        return Icons.info;

      case "mortarpestle":
        return Icons.info;

      case "solidmoon":
        return Icons.info;

      case "moon":
        return Icons.info;

      case "monument":
        return Icons.info;

      case "moneycheckalt":
        return Icons.info;

      case "motorcycle":
        return Icons.info;

      case "mountain":
        return Icons.info;

      case "mousepointer":
        return Icons.info;

      case "newspaper":
        return Icons.info;

      case "neuter":
        return Icons.info;

      case "networkwired":
        return Icons.info;

      case "neos":
        return Icons.info;

      case "napster":
        return Icons.info;

      case "music":
        return Icons.info;

      case "mughot":
        return Icons.info;

      case "solidnewspaper":
        return Icons.info;

      case "nimblr":
        return Icons.info;

      case "node":
        return Icons.info;

      case "nodejs":
        return Icons.info;

      case "notequal":
        return Icons.info;

      case "nutritionix":
        return Icons.info;

      case "ns8":
        return Icons.info;

      case "npm":
        return Icons.info;

      case "notesmedical":
        return Icons.info;

      case "objectgroup":
        return Icons.info;

      case "solidobjectgroup":
        return Icons.info;

      case "objectungroup":
        return Icons.info;

      case "solidobjectungroup":
        return Icons.info;

      case "oldrepublic":
        return Icons.info;

      case "odnoklassniki":
        return Icons.info;

      case "odnoklassnikisquare":
        return Icons.info;

      case "oilcan":
        return Icons.info;

      case "optinmonster":
        return Icons.info;

      case "opera":
        return Icons.info;

      case "openid":
        return Icons.info;

      case "opencart":
        return Icons.info;

      case "om":
        return Icons.info;

      case "osi":
        return Icons.info;

      case "otter":
        return Icons.info;

      case "outdent":
        return Icons.info;

      case "page4":
        return Icons.info;

      case "pagelines":
        return Icons.info;

      case "pager":
        return Icons.info;

      case "paintbrush":
        return Icons.info;

      case "paintroller":
        return Icons.info;

      case "palette":
        return Icons.info;

      case "palfed":
        return Icons.info;

      case "pallet":
        return Icons.info;

      case "paperplane":
        return Icons.info;

      case "solidpaperplane":
        return Icons.info;

      case "paragraph":
        return Icons.info;

      case "parachutebox":
        return Icons.info;

      case "paperclip":
        return Icons.info;

      case "parking":
        return Icons.info;

      case "patreon":
        return Icons.info;

      case "paste":
        return Icons.info;

      case "pastafarianism":
        return Icons.info;

      case "passport":
        return Icons.info;

      case "pause":
        return Icons.info;

      case "pausecircle":
        return Icons.info;

      case "solidpausecircle":
        return Icons.info;

      case "paw":
        return Icons.info;

      case "paypal":
        return Icons.info;

      case "pennib":
        return Icons.info;

      case "penfancy":
        return Icons.info;

      case "penalt":
        return Icons.info;

      case "pen":
        return Icons.info;

      case "peace":
        return Icons.info;

      case "pepperhot":
        return Icons.info;

      case "percent":
        return Icons.info;

      case "percentage":
        return Icons.info;

      case "phoenixframework":
        return Icons.info;

      case "pensquare":
        return Icons.info;

      case "peoplecarry":
        return Icons.info;

      case "pennyarcade":
        return Icons.info;

      case "pencilruler":
        return Icons.info;

      case "pencilalt":
        return Icons.info;

      case "periscope":
        return Icons.info;

      case "personbooth":
        return Icons.info;

      case "phabricator":
        return Icons.info;

      case "phoenixsquadron":
        return Icons.info;

      case "phone":
        return Icons.info;

      case "phoneslash":
        return Icons.info;

      case "phonesquare":
        return Icons.info;

      case "phonevolume":
        return Icons.info;

      case "php":
        return Icons.info;

      case "pinterest":
        return Icons.info;

      case "pills":
        return Icons.info;

      case "piggybank":
        return Icons.info;

      case "piedpiperpp":
        return Icons.info;

      case "piedpiperhat":
        return Icons.info;

      case "piedpiperalt":
        return Icons.info;

      case "piedpiper":
        return Icons.info;

      case "placeofworship":
        return Icons.info;

      case "pizzaslice":
        return Icons.info;

      case "pinterestsquare":
        return Icons.info;

      case "pinterestp":
        return Icons.info;

      case "playcircle":
        return Icons.info;

      case "play":
        return Icons.info;

      case "planedeparture":
        return Icons.info;

      case "planearrival":
        return Icons.info;

      case "plane":
        return Icons.info;

      case "pluscircle":
        return Icons.info;

      case "plus":
        return Icons.info;

      case "plug":
        return Icons.info;

      case "playstation":
        return Icons.info;

      case "solidplaycircle":
        return Icons.info;

      case "poll":
        return Icons.info;

      case "podcast":
        return Icons.info;

      case "solidplussquare":
        return Icons.info;

      case "plussquare":
        return Icons.info;

      case "poundsign":
        return Icons.info;

      case "portrait":
        return Icons.info;

      case "poop":
        return Icons.info;

      case "poostorm":
        return Icons.info;

      case "poo":
        return Icons.info;

      case "pollh":
        return Icons.info;

      case "poweroff":
        return Icons.info;

      case "pray":
        return Icons.info;

      case "puzzlepiece":
        return Icons.info;

      case "prescription":
        return Icons.info;

      case "prescriptionbottle":
        return Icons.info;

      case "prescriptionbottlealt":
        return Icons.info;

      case "prayinghands":
        return Icons.info;

      case "print":
        return Icons.info;

      case "procedures":
        return Icons.info;

      case "producthunt":
        return Icons.info;

      case "projectdiagram":
        return Icons.info;

      case "pushed":
        return Icons.info;

      case "qq":
        return Icons.info;

      case "python":
        return Icons.info;

      case "questioncircle":
        return Icons.info;

      case "question":
        return Icons.info;

      case "qrcode":
        return Icons.info;

      case "solidquestioncircle":
        return Icons.info;

      case "quidditch":
        return Icons.info;

      case "quinscape":
        return Icons.info;

      case "quora":
        return Icons.info;

      case "quoteleft":
        return Icons.info;

      case "quoteright":
        return Icons.info;

      case "quran":
        return Icons.info;

      case "radiation":
        return Icons.info;

      case "rproject":
        return Icons.info;

      case "reacteurope":
        return Icons.info;

      case "react":
        return Icons.info;

      case "ravelry":
        return Icons.info;

      case "raspberrypi":
        return Icons.info;

      case "random":
        return Icons.info;

      case "rainbow":
        return Icons.info;

      case "radiationalt":
        return Icons.info;

      case "reddit":
        return Icons.info;

      case "redriver":
        return Icons.info;

      case "recycle":
        return Icons.info;

      case "receipt":
        return Icons.info;

      case "rebel":
        return Icons.info;

      case "readme":
        return Icons.info;

      case "redhat":
        return Icons.info;

      case "redditsquare":
        return Icons.info;

      case "redditalien":
        return Icons.info;

      case "redo":
        return Icons.info;

      case "redoalt":
        return Icons.info;

      case "registered":
        return Icons.info;

      case "solidregistered":
        return Icons.info;

      case "renren":
        return Icons.info;

      case "reply":
        return Icons.info;

      case "replyall":
        return Icons.info;

      case "replyd":
        return Icons.info;

      case "republican":
        return Icons.info;

      case "rev":
        return Icons.info;

      case "retweet":
        return Icons.info;

      case "restroom":
        return Icons.info;

      case "resolving":
        return Icons.info;

      case "researchgate":
        return Icons.info;

      case "ribbon":
        return Icons.info;

      case "route":
        return Icons.info;

      case "rockrms":
        return Icons.info;

      case "rocketchat":
        return Icons.info;

      case "rocket":
        return Icons.info;

      case "robot":
        return Icons.info;

      case "road":
        return Icons.info;

      case "ring":
        return Icons.info;

      case "rss":
        return Icons.info;

      case "rsssquare":
        return Icons.info;

      case "sadcry":
        return Icons.info;

      case "rupeesign":
        return Icons.info;

      case "running":
        return Icons.info;

      case "rulervertical":
        return Icons.info;

      case "rulerhorizontal":
        return Icons.info;

      case "rulercombined":
        return Icons.info;

      case "ruler":
        return Icons.info;

      case "rublesign":
        return Icons.info;

      case "solidsadcry":
        return Icons.info;

      case "sadtear":
        return Icons.info;

      case "solidsadtear":
        return Icons.info;

      case "safari":
        return Icons.info;

      case "sass":
        return Icons.info;

      case "satellite":
        return Icons.info;

      case "satellitedish":
        return Icons.info;

      case "save":
        return Icons.info;

      case "solidsave":
        return Icons.info;

      case "schlix":
        return Icons.info;

      case "school":
        return Icons.info;

      case "screwdriver":
        return Icons.info;

      case "scribd":
        return Icons.info;

      case "searchminus":
        return Icons.info;

      case "searchlocation":
        return Icons.info;

      case "searchdollar":
        return Icons.info;

      case "search":
        return Icons.info;

      case "sdcard":
        return Icons.info;

      case "scroll":
        return Icons.info;

      case "searchplus":
        return Icons.info;

      case "searchengin":
        return Icons.info;

      case "seedling":
        return Icons.info;

      case "sellcast":
        return Icons.info;

      case "sellsy":
        return Icons.info;

      case "server":
        return Icons.info;

      case "servicestack":
        return Icons.info;

      case "sharealtsquare":
        return Icons.info;

      case "sharealt":
        return Icons.info;

      case "share":
        return Icons.info;

      case "shapes":
        return Icons.info;

      case "sharesquare":
        return Icons.info;

      case "solidsharesquare":
        return Icons.info;

      case "shekelsign":
        return Icons.info;

      case "shieldalt":
        return Icons.info;

      case "ship":
        return Icons.info;

      case "shippingfast":
        return Icons.info;

      case "shirtsinbulk":
        return Icons.info;

      case "shoeprints":
        return Icons.info;

      case "shuttlevan":
        return Icons.info;

      case "shower":
        return Icons.info;

      case "shopware":
        return Icons.info;

      case "shoppingcart":
        return Icons.info;

      case "shoppingbag":
        return Icons.info;

      case "shoppingbasket":
        return Icons.info;

      case "sign":
        return Icons.info;

      case "signinalt":
        return Icons.info;

      case "signlanguage":
        return Icons.info;

      case "signoutalt":
        return Icons.info;

      case "signal":
        return Icons.info;

      case "signature":
        return Icons.info;

      case "simcard":
        return Icons.info;

      case "simplybuilt":
        return Icons.info;

      case "sistrix":
        return Icons.info;

      case "sitemap":
        return Icons.info;

      case "sith":
        return Icons.info;

      case "skating":
        return Icons.info;

      case "skyatlas":
        return Icons.info;

      case "skullcrossbones":
        return Icons.info;

      case "skull":
        return Icons.info;

      case "skiingnordic":
        return Icons.info;

      case "skiing":
        return Icons.info;

      case "sketch":
        return Icons.info;

      case "sleigh":
        return Icons.info;

      case "slash":
        return Icons.info;

      case "slackhash":
        return Icons.info;

      case "slack":
        return Icons.info;

      case "skype":
        return Icons.info;

      case "solidsmile":
        return Icons.info;

      case "smile":
        return Icons.info;

      case "slideshare":
        return Icons.info;

      case "slidersh":
        return Icons.info;

      case "smilebeam":
        return Icons.info;

      case "solidsmilebeam":
        return Icons.info;

      case "smilewink":
        return Icons.info;

      case "sms":
        return Icons.info;

      case "smokingban":
        return Icons.info;

      case "smoking":
        return Icons.info;

      case "smog":
        return Icons.info;

      case "solidsmilewink":
        return Icons.info;

      case "solidsnowflake":
        return Icons.info;

      case "snowflake":
        return Icons.info;

      case "snowboarding":
        return Icons.info;

      case "snapchatsquare":
        return Icons.info;

      case "snapchatghost":
        return Icons.info;

      case "snapchat":
        return Icons.info;

      case "socks":
        return Icons.info;

      case "snowplow":
        return Icons.info;

      case "snowman":
        return Icons.info;

      case "sortalphaup":
        return Icons.info;

      case "sortalphadown":
        return Icons.info;

      case "sort":
        return Icons.info;

      case "solarpanel":
        return Icons.info;

      case "sortnumericup":
        return Icons.info;

      case "sortnumericdown":
        return Icons.info;

      case "sortdown":
        return Icons.info;

      case "sortamountup":
        return Icons.info;

      case "sortamountdown":
        return Icons.info;

      case "sortup":
        return Icons.info;

      case "soundcloud":
        return Icons.info;

      case "sourcetree":
        return Icons.info;

      case "spa":
        return Icons.info;

      case "splotch":
        return Icons.info;

      case "spinner":
        return Icons.info;

      case "spider":
        return Icons.info;

      case "speakap":
        return Icons.info;

      case "spaceshuttle":
        return Icons.info;

      case "solidsquare":
        return Icons.info;

      case "square":
        return Icons.info;

      case "spraycan":
        return Icons.info;

      case "spotify":
        return Icons.info;

      case "stackexchange":
        return Icons.info;

      case "squarespace":
        return Icons.info;

      case "squarerootalt":
        return Icons.info;

      case "squarefull":
        return Icons.info;

      case "starandcrescent":
        return Icons.info;

      case "solidstar":
        return Icons.info;

      case "star":
        return Icons.info;

      case "stamp":
        return Icons.info;

      case "stackoverflow":
        return Icons.info;

      case "steam":
        return Icons.info;

      case "starhalfalt":
        return Icons.info;

      case "solidstarhalf":
        return Icons.info;

      case "starhalf":
        return Icons.info;

      case "staylinked":
        return Icons.info;

      case "staroflife":
        return Icons.info;

      case "starofdavid":
        return Icons.info;

      case "stickynote":
        return Icons.info;

      case "stickermule":
        return Icons.info;

      case "stethoscope":
        return Icons.info;

      case "stepforward":
        return Icons.info;

      case "stepbackward":
        return Icons.info;

      case "steamsymbol":
        return Icons.info;

      case "steamsquare":
        return Icons.info;

      case "solidstickynote":
        return Icons.info;

      case "stop":
        return Icons.info;

      case "streetview":
        return Icons.info;

      case "stream":
        return Icons.info;

      case "strava":
        return Icons.info;

      case "storealt":
        return Icons.info;

      case "store":
        return Icons.info;

      case "stopwatch":
        return Icons.info;

      case "solidstopcircle":
        return Icons.info;

      case "stopcircle":
        return Icons.info;

      case "strikethrough":
        return Icons.info;

      case "stripe":
        return Icons.info;

      case "stripes":
        return Icons.info;

      case "stroopwafel":
        return Icons.info;

      case "studiovinari":
        return Icons.info;

      case "stumbleupon":
        return Icons.info;

      case "stumbleuponcircle":
        return Icons.info;

      case "subway":
        return Icons.info;

      case "subscript":
        return Icons.info;

      case "suitcase":
        return Icons.info;

      case "suitcaserolling":
        return Icons.info;

      case "superpowers":
        return Icons.info;

      case "solidsun":
        return Icons.info;

      case "sun":
        return Icons.info;

      case "swatchbook":
        return Icons.info;

      case "suse":
        return Icons.info;

      case "solidsurprise":
        return Icons.info;

      case "surprise":
        return Icons.info;

      case "supple":
        return Icons.info;

      case "superscript":
        return Icons.info;

      case "swimmer":
        return Icons.info;

      case "swimmingpool":
        return Icons.info;

      case "synagogue":
        return Icons.info;

      case "sync":
        return Icons.info;

      case "syncalt":
        return Icons.info;

      case "syringe":
        return Icons.info;

      case "tablets":
        return Icons.info;

      case "tabletalt":
        return Icons.info;

      case "tablet":
        return Icons.info;

      case "tabletennis":
        return Icons.info;

      case "table":
        return Icons.info;

      case "tachometeralt":
        return Icons.info;

      case "tag":
        return Icons.info;

      case "tags":
        return Icons.info;

      case "tape":
        return Icons.info;

      case "tasks":
        return Icons.info;

      case "taxi":
        return Icons.info;

      case "teamspeak":
        return Icons.info;

      case "tenge":
        return Icons.info;

      case "teeth":
        return Icons.info;

      case "teethopen":
        return Icons.info;

      case "telegram":
        return Icons.info;

      case "telegramplane":
        return Icons.info;

      case "temperaturelow":
        return Icons.info;

      case "tencentweibo":
        return Icons.info;

      case "temperaturehigh":
        return Icons.info;

      case "terminal":
        return Icons.info;

      case "textheight":
        return Icons.info;

      case "textwidth":
        return Icons.info;

      case "th":
        return Icons.info;

      case "thlarge":
        return Icons.info;

      case "thlist":
        return Icons.info;

      case "themeco":
        return Icons.info;

      case "theatermasks":
        return Icons.info;

      case "theredyeti":
        return Icons.info;

      case "themeisle":
        return Icons.info;

      case "thermometer":
        return Icons.info;

      case "thermometerempty":
        return Icons.info;

      case "thermometerfull":
        return Icons.info;

      case "thumbsdown":
        return Icons.info;

      case "thinkpeaks":
        return Icons.info;

      case "thermometerquarter":
        return Icons.info;

      case "thermometerhalf":
        return Icons.info;

      case "solidthumbsdown":
        return Icons.info;

      case "solidtimescircle":
        return Icons.info;

      case "timescircle":
        return Icons.info;

      case "times":
        return Icons.info;

      case "ticketalt":
        return Icons.info;

      case "solidthumbsup":
        return Icons.info;

      case "thumbtack":
        return Icons.info;

      case "thumbsup":
        return Icons.info;

      case "tint":
        return Icons.info;

      case "tintslash":
        return Icons.info;

      case "tired":
        return Icons.info;

      case "solidtired":
        return Icons.info;

      case "toggleoff":
        return Icons.info;

      case "toggleon":
        return Icons.info;

      case "toilet":
        return Icons.info;

      case "toiletpaper":
        return Icons.info;

      case "toolbox":
        return Icons.info;

      case "tools":
        return Icons.info;

      case "toriigate":
        return Icons.info;

      case "torah":
        return Icons.info;

      case "tooth":
        return Icons.info;

      case "tractor":
        return Icons.info;

      case "tradefederation":
        return Icons.info;

      case "trademark":
        return Icons.info;

      case "trafficlight":
        return Icons.info;

      case "train":
        return Icons.info;

      case "tram":
        return Icons.info;

      case "transgender":
        return Icons.info;

      case "transgenderalt":
        return Icons.info;

      case "trash":
        return Icons.info;

      case "trashalt":
        return Icons.info;

      case "solidtrashalt":
        return Icons.info;

      case "trashrestore":
        return Icons.info;

      case "trashrestorealt":
        return Icons.info;

      case "tree":
        return Icons.info;

      case "trello":
        return Icons.info;

      case "tripadvisor":
        return Icons.info;
//
//         case "trophy":

      case "truck":
        return Icons.info;

      case "truckloading":
        return Icons.info;

      case "truckmonster":
        return Icons.info;

      case "truckmoving":
        return Icons.info;

      case "truckpickup":
        return Icons.info;

      case "tshirt":
        return Icons.info;

      case "tty":
        return Icons.info;

      case "tumblr":
        return Icons.info;

      case "tumblrsquare":
        return Icons.info;

      case "tv":
        return Icons.info;

      case "twitch":
        return Icons.info;

      case "twitter":
        return Icons.info;

      case "twittersquare":
        return Icons.info;

      case "typo3":
        return Icons.info;

      case "undoalt":
        return Icons.info;

      case "undo":
        return Icons.info;

      case "underline":
        return Icons.info;

      case "umbrellabeach":
        return Icons.info;

      case "umbrella":
        return Icons.info;

      case "uikit":
        return Icons.info;

      case "ubuntu":
        return Icons.info;

      case "uber":
        return Icons.info;

      case "university":
        return Icons.info;

      case "unlink":
        return Icons.info;

      case "universalaccess":
        return Icons.info;

      case "uniregistry":
        return Icons.info;

      case "ups":
        return Icons.info;

      case "upload":
        return Icons.info;

      case "untappd":
        return Icons.info;

      case "unlockalt":
        return Icons.info;

      case "unlock":
        return Icons.info;

      case "usb":
        return Icons.info;

      case "user":
        return Icons.info;

      case "soliduser":
        return Icons.info;

      case "useralt":
        return Icons.info;

      case "useraltslash":
        return Icons.info;

      case "userastronaut":
        return Icons.info;

      case "usercheck":
        return Icons.info;

      case "usercircle":
        return Icons.info;

      case "solidusercircle":
        return Icons.info;

      case "userclock":
        return Icons.info;

      case "usercog":
        return Icons.info;

      case "userlock":
        return Icons.info;

      case "userinjured":
        return Icons.info;

      case "usergraduate":
        return Icons.info;

      case "userfriends":
        return Icons.info;

      case "useredit":
        return Icons.info;

      case "usermd":
        return Icons.info;

      case "userminus":
        return Icons.info;

      case "userninja":
        return Icons.info;

      case "usernurse":
        return Icons.info;

      case "userplus":
        return Icons.info;

      case "usersecret":
        return Icons.info;

      case "usershield":
        return Icons.info;

      case "userslash":
        return Icons.info;

      case "usertag":
        return Icons.info;

      case "usertie":
        return Icons.info;

      case "usertimes":
        return Icons.info;

      case "users":
        return Icons.info;

      case "userscog":
        return Icons.info;

      case "usps":
        return Icons.info;

      case "ussunnah":
        return Icons.info;

      case "utensilspoon":
        return Icons.info;

      case "utensils":
        return Icons.info;

      case "vaadin":
        return Icons.info;

      case "vectorsquare":
        return Icons.info;

      case "venus":
        return Icons.info;

      case "venusdouble":
        return Icons.info;

      case "venusmars":
        return Icons.info;

      case "viacoin":
        return Icons.info;

      case "viadeo":
        return Icons.info;

      case "viadeosquare":
        return Icons.info;

      case "vial":
        return Icons.info;

      case "vials":
        return Icons.info;

      case "viber":
        return Icons.info;

      case "video":
        return Icons.info;

      case "vihara":
        return Icons.info;

      case "videoslash":
        return Icons.info;

      case "vimeo":
        return Icons.info;

      case "vimeosquare":
        return Icons.info;

      case "vimeov":
        return Icons.info;

      case "vine":
        return Icons.info;

      case "vk":
        return Icons.info;

      case "vnv":
        return Icons.info;

      case "volumedown":
        return Icons.info;

      case "volumemute":
        return Icons.info;

      case "volumeoff":
        return Icons.info;

      case "volumeup":
        return Icons.info;

      case "voteyea":
        return Icons.info;

      case "water":
        return Icons.info;

      case "wallet":
        return Icons.info;

      case "walking":
        return Icons.info;

      case "vuejs":
        return Icons.info;

      case "vrcardboard":
        return Icons.info;

      case "weighthanging":
        return Icons.info;

      case "weebly":
        return Icons.info;

      case "weibo":
        return Icons.info;

      case "weight":
        return Icons.info;

      case "weixin":
        return Icons.info;

      case "whatsapp":
        return Icons.info;

      case "whatsappsquare":
        return Icons.info;

      case "wheelchair":
        return Icons.info;

      case "windowclose":
        return Icons.info;

      case "wind":
        return Icons.info;

      case "wikipediaw":
        return Icons.info;

      case "wifi":
        return Icons.info;

      case "whmcs":
        return Icons.info;

      case "solidwindowclose":
        return Icons.info;

      case "windowmaximize":
        return Icons.info;

      case "solidwindowmaximize":
        return Icons.info;

      case "windowminimize":
        return Icons.info;

      case "solidwindowminimize":
        return Icons.info;

      case "windowrestore":
        return Icons.info;

      case "solidwindowrestore":
        return Icons.info;

      case "windows":
        return Icons.info;

      case "winebottle":
        return Icons.info;

      case "wizardsofthecoast":
        return Icons.info;

      case "wix":
        return Icons.info;

      case "wineglassalt":
        return Icons.info;

      case "wineglass":
        return Icons.info;

      case "wordpresssimple":
        return Icons.info;

      case "wordpress":
        return Icons.info;

      case "wonsign":
        return Icons.info;

      case "wolfpackbattalion":
        return Icons.info;

      case "xray":
        return Icons.info;

      case "wrench":
        return Icons.info;

      case "wpforms":
        return Icons.info;

      case "wpressr":
        return Icons.info;

      case "wpexplorer":
        return Icons.info;

      case "wpbeginner":
        return Icons.info;

      case "xbox":
        return Icons.info;

      case "xing":
        return Icons.info;

      case "yandex":
        return Icons.info;

      case "xingsquare":
        return Icons.info;

      case "ycombinator":
        return Icons.info;

      case "yahoo":
        return Icons.info;

      case "yandexinternational":
        return Icons.info;

      case "yarn":
        return Icons.info;

      case "yelp":
        return Icons.info;

      case "yensign":
        return Icons.info;

      case "yinyang":
        return Icons.info;

      case "yoast":
        return Icons.info;

      case "youtube":
        return Icons.info;

      case "youtubesquare":
        return Icons.info;

      case "zhihu":
        return Icons.info;

      default:
        return Icons.info;
    }
  }
}

