/*
Navicat MySQL Data Transfer

Source Server         : Localhost
Source Server Version : 50509
Source Host           : localhost:3306
Source Database       : alyx_common

Target Server Type    : MYSQL
Target Server Version : 50509
File Encoding         : 65001

Date: 2011-03-01 20:44:15
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `snippets`
-- ----------------------------
DROP TABLE IF EXISTS `snippets`;
CREATE TABLE `snippets` (
  `snippetId` varchar(50) NOT NULL DEFAULT '',
  `pageId` varchar(50) NOT NULL DEFAULT '',
  `snippet` longtext,
  PRIMARY KEY (`snippetId`,`pageId`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of snippets
-- ----------------------------
INSERT INTO snippets VALUES ('countries_long', '_common', 'US|United States,CA|Canada,AF|Afghanistan,AL|Albania,DZ|Algeria,AS|American Samoa,AD|Andorra,AO|Angola,AI|Anguilla,AQ|Antarctica,AG|Antigua and Barbuda,AR|Argentina,AM|Armenia,AW|Aruba,AU|Australia,AT|Austria,AZ|Azerbaijan,BS|Bahamas,BH|Bahrain,BD|Bangladesh,BB|Barbados,BY|Belarus,BE|Belgium,BZ|Belize,BJ|Benin,BM|Bermuda,BT|Bhutan,BO|Bolivia,BA|Bosnia and Herzegovina,BW|Botswana,BV|Bouvet Island,BR|Brazil,IO|British Indian Ocean Territory,BN|Brunei Darussalam,BG|Bulgaria,BF|Burkina Faso,BI|Burundi,KH|Cambodia,CM|Cameroon,CV|Cape Verde,KY|Cayman Islands,CF|Central African Republic,TD|Chad,CL|Chile,CN|China,CX|Christmas Island,CC|Cocos (Keeling) Islands,CO|Colombia,KM|Comoros,CG|Congo,CK|Cook Islands,CR|Costa Rica,CI|Cote D\'Ivoire (Ivory Coast),HR|Croatia (Hrvatska),CU|Cuba,CY|Cyprus,CZ|Czech Republic,CS|Czechoslovakia (former),DK|Denmark,DJ|Djibouti,DM|Dominica,DO|Dominican Republic,TP|East Timor,EC|Ecuador,EG|Egypt,SV|El Salvador,GQ|Equatorial Guinea,ER|Eritrea,EE|Estonia,ET|Ethiopia,FK|Falkland Islands (Malvinas),FO|Faroe Islands,FJ|Fiji,FI|Finland,FR|France,FX|France Metropolitan,GF|French Guiana,PF|French Polynesia,TF|French Southern Territories,GA|Gabon,GM|Gambia,GE|Georgia,DE|Germany,GH|Ghana,GI|Gibraltar,GB|Great Britain (UK),GR|Greece,GL|Greenland,GD|Grenada,GP|Guadeloupe,GU|Guam,GT|Guatemala,GN|Guinea,GW|Guinea-Bissau,GY|Guyana,HT|Haiti,HM|Heard and McDonald Islands,HN|Honduras,HK|Hong Kong,HU|Hungary,IS|Iceland,IN|India,ID|Indonesia,IR|Iran,IQ|Iraq,IE|Ireland,IL|Israel,IT|Italy,JM|Jamaica,JP|Japan,JO|Jordan,KZ|Kazakhstan,KE|Kenya,KI|Kiribati,KP|Korea (North),KR|Korea (South),KW|Kuwait,KG|Kyrgyzstan,LA|Laos,LV|Latvia,LB|Lebanon,LS|Lesotho,LR|Liberia,LY|Libya,LI|Liechtenstein,LT|Lithuania,LU|Luxembourg,MO|Macau,MK|Macedonia,MG|Madagascar,MW|Malawi,MY|Malaysia,MV|Maldives,ML|Mali,MT|Malta,MH|Marshall Islands,MQ|Martinique,MR|Mauritania,MU|Mauritius,YT|Mayotte,MX|Mexico,FM|Micronesia,MD|Moldova,MC|Monaco,MN|Mongolia,MS|Montserrat,MA|Morocco,MZ|Mozambique,MM|Myanmar,NA|Namibia,NR|Nauru,NP|Nepal,NL|Netherlands,AN|Netherlands Antilles,NT|Neutral Zone,NC|New Caledonia,NZ|New Zealand,NI|Nicaragua,NE|Niger,NG|Nigeria,NU|Niue,NF|Norfolk Island,MP|Northern Mariana Islands,NO|Norway,OM|Oman,PK|Pakistan,PW|Palau,PA|Panama,PG|Papua New Guinea,PY|Paraguay,PE|Peru,PH|Philippines,PN|Pitcairn,PL|Poland,PT|Portugal,PR|Puerto Rico,QA|Qatar,RE|Reunion,RO|Romania,RU|Russian Federation,RW|Rwanda,GS|S. Georgia and S. Sandwich Isls.,KN|Saint Kitts and Nevis,LC|Saint Lucia,VC|Saint Vincent and the Grenadines,WS|Samoa,SM|San Marino,ST|Sao Tome and Principe,SA|Saudi Arabia,SN|Senegal,SC|Seychelles,SL|Sierra Leone,SG|Singapore,SK|Slovak Republic,SI|Slovenia,Sb|Solomon Islands,SO|Somalia,ZA|South Africa,ES|Spain,LK|Sri Lanka,SH|St. Helena,PM|St. Pierre and Miquelon,SD|Sudan,SR|Suriname,SJ|Svalbard and Jan Mayen Islands,SZ|Swaziland,SE|Sweden,CH|Switzerland,SY|Syria,TW|Taiwan,TJ|Tajikistan,TZ|Tanzania,TH|Thailand,TG|Togo,TK|Tokelau,TO|Tonga,TT|Trinidad and Tobago,TN|Tunisia,TR|Turkey,TM|Turkmenistan,TC|Turks and Caicos Islands,TV|Tuvalu,UG|Uganda,UA|Ukraine,AE|United Arab Emirates,UK|United Kingdom,UY|Uruguay,UM|US Minor Outlying Islands,SU|USSR (former),UZ|Uzbekistan,VU|Vanuatu,VA|Vatican City State (Holy See),VE|Venezuela,VN|Viet Nam,VG|Virgin Islands (British),VI|Virgin Islands (U.S.),WF|Wallis and Futuna Islands,EH|Western Sahara,YE|Yemen,YU|Yugoslavia,ZR|Zaire,ZM|Zambia,ZW|Zimbabwe');
INSERT INTO snippets VALUES ('decimalonly', '_errormessages', '%%fieldname%% must be a valid decimal amount.');
INSERT INTO snippets VALUES ('pci_password', '_regexp', '^.*(?=.{8,})(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).*$');
INSERT INTO snippets VALUES ('pci_password_message', '_common', 'Your password must be at least 8 characters and must contain at least 1 upper case character, 1 lower case character, and 1 numeric digit.');
INSERT INTO snippets VALUES ('imagefilesonly', '_errormessages', '%%fieldname%% must be an image file.');
INSERT INTO snippets VALUES ('docfilesonly', '_errormessages', '%%fieldname%% must be a document file.');
INSERT INTO snippets VALUES ('pdffilesonly', '_errormessages', '%%fieldname%% must be a PDF file.');
INSERT INTO snippets VALUES ('alphanumericspaceonly', '_errormessages', '%%fieldname%% must contain only letters, numbers and spaces.');
INSERT INTO snippets VALUES ('countries_short', '_common', 'AD,AE,AF,AG,AI,AL,AM,AN,AO,AQ,AR,AS,AT,AU,AW,AZ,BA,BB,BD,BE,BF,BG,BH,BI,BJ,BM,BN,BO,BR,BS,BT,BV,BW,BY,BZ,CA,CC,CF,CG,CH,CI,CK,CL,CM,CN,CO,CR,CS,CU,CV,CX,CY,CZ,DE,DJ,DK,DM,DO,DZ,EC,EE,EG,EH,ER,ES,ET,FI,FJ,FK,FM,FO,FR,FX,GA,GB,GD,GE,GF,GH,GI,GL,GM,GN,GP,GQ,GR,GS,GT,GU,GW,GY,HK,HM,HN,HR,HT,HU,ID,IE,IL,IN,IO,IQ,IR,IS,IT,JM,JO,JP,KE,KG,KH,KI,KM,KN,KP,KR,KW,KY,KZ,LA,LB,LC,LI,LK,LR,LS,LT,LU,LV,LY,MA,MC,MD,MG,MH,MK,ML,MM,MN,MO,MP,MQ,MR,MS,MT,MU,MV,MW,MX,MY,MZ,NA,NC,NE,NF,NG,NI,NL,NO,NP,NR,NT,NU,NZ,OM,PA,PE,PF,PG,PH,PK,PL,PM,PN,PR,PT,PW,PY,QA,RE,RO,RU,RW,SA,SC,SD,SE,SG,SH,SI,SJ,SK,SL,SM,SN,SO,SR,ST,SU,SV,SY,SZ,Sb,TC,TD,TF,TG,TH,TJ,TK,TM,TN,TO,TP,TR,TT,TV,TW,TZ,UA,UG,UK,UM,US,UY,UZ,VA,VC,VE,VG,VI,VN,VU,WF,WS,YE,YT,YU,ZA,ZM,ZR,ZW');
INSERT INTO snippets VALUES ('addressnopobox', '_errormessages', '%%fieldname%% must not be a P.O. box.');
INSERT INTO snippets VALUES ('alphanumericonly', '_errormessages', '%%fieldname%% must contain only letters and numbers.');
INSERT INTO snippets VALUES ('alphaonly', '_errormessages', '%%fieldname%% must contain only letters.');
INSERT INTO snippets VALUES ('alphaspaceonly', '_errormessages', '%%fieldname%% must contain only letters and spaces.');
INSERT INTO snippets VALUES ('bankroutingbadformat', '_errormessages', '%%fieldname%% is not a valid routing number.');
INSERT INTO snippets VALUES ('birthdatetooold', '_errormessages', '%%fieldname%% must be no more than %%maximum%% years of age.');
INSERT INTO snippets VALUES ('birthdatetooyoung', '_errormessages', '%%fieldname%% must be at least %%minimum%% years of age.');
INSERT INTO snippets VALUES ('ccdateinvalid', '_errormessages', '%%fieldname%% is not a valid credit card expiration date.');
INSERT INTO snippets VALUES ('clientsidefooter', '_errormessages', '\r\n\r\nPlease make corrections and re-submit.');
INSERT INTO snippets VALUES ('counttoofew', '_errormessages', 'At least one %%fieldname%% must be entered.');
INSERT INTO snippets VALUES ('counttoomany', '_errormessages', 'Only one %%fieldname%% can be entered.');
INSERT INTO snippets VALUES ('currencybadformat', '_errormessages', '%%fieldname%% must contain a valid amount of money.');
INSERT INTO snippets VALUES ('currencyprecision', '_errormessages', '%%fieldname%% must be a multiple of %%maximum%%.');
INSERT INTO snippets VALUES ('datebadformat', '_errormessages', '%%fieldname%% is not a valid date.');
INSERT INTO snippets VALUES ('datedayinvalid', '_errormessages', '%%fieldname%% must be between %%minimum%% and %%maximum%%.');
INSERT INTO snippets VALUES ('datefutureonly', '_errormessages', '%%fieldname%% must specify a date in the future.');
INSERT INTO snippets VALUES ('dateinvalid', '_errormessages', '%%fieldname%% is invalid; the day must be between %%minimum%% and %%maximum%%.');
INSERT INTO snippets VALUES ('datemonthinvalid', '_errormessages', '%%fieldname%% must be between %%minimum%% and %%maximum%%.');
INSERT INTO snippets VALUES ('datepastonly', '_errormessages', '%%fieldname%% must specify a date in the past.');
INSERT INTO snippets VALUES ('daterangeinvalid', '_errormessages', 'The selected date range is invalid.');
INSERT INTO snippets VALUES ('dateyearinvalid', '_errormessages', '%%fieldname%% must be between %%minimum%% and %%maximum%%.');
INSERT INTO snippets VALUES ('discoverbadfmt', '_errormessages', '%%fieldname%% must be a valid Discover card number.');
INSERT INTO snippets VALUES ('emailbadformat', '_errormessages', '%%fieldname%% must be a valid e-mail address.');
INSERT INTO snippets VALUES ('embosscharsonly', '_errormessages', '%%fieldname%% must contain only letters, numbers, dashes, and spaces.');
INSERT INTO snippets VALUES ('floatbadformat', '_errormessages', '%%fieldname%% must contain a valid number.');
INSERT INTO snippets VALUES ('floatprecision', '_errormessages', '%%fieldname%% must be a multiple of %%maximum%%.');
INSERT INTO snippets VALUES ('general', '_errormessages', 'There was an error completing your request.');
INSERT INTO snippets VALUES ('grouprequired', '_errormessages', 'All %%fieldname%% are required.');
INSERT INTO snippets VALUES ('implicitfailure', '_errormessages', '');
INSERT INTO snippets VALUES ('listbadvalue', '_errormessages', '%%fieldname%% is not a valid entry.');
INSERT INTO snippets VALUES ('mastercardbadformat', '_errormessages', '%%fieldname%% must be a valid MasterCard card number.');
INSERT INTO snippets VALUES ('maxdate', '_errormessages', '%%fieldname%% must be on or before %%maximum%%.');
INSERT INTO snippets VALUES ('maxlength', '_errormessages', '%%fieldname%% must be %%maximum%% characters or less.');
INSERT INTO snippets VALUES ('maxvalue', '_errormessages', '%%fieldname%% must be %%maximum%% or less.');
INSERT INTO snippets VALUES ('mindate', '_errormessages', '%%fieldname%% must be on or after %%minimum%%.');
INSERT INTO snippets VALUES ('minlength', '_errormessages', '%%fieldname%% must be %%minimum%% characters or more.');
INSERT INTO snippets VALUES ('minvalue', '_errormessages', '%%fieldname%% must be %%minimum%% or more.');
INSERT INTO snippets VALUES ('mustmatch', '_errormessages', '%%fieldname%% must match.');
INSERT INTO snippets VALUES ('mustnotmatch', '_errormessages', '%%fieldname%% must not match.');
INSERT INTO snippets VALUES ('namecharsonly', '_errormessages', '%%fieldname%% contains invalid characters.');
INSERT INTO snippets VALUES ('nomatchingaccount', '_errormessages', 'No Matching Account Found');
INSERT INTO snippets VALUES ('integeronly', '_errormessages', '%%fieldname%% must contain only digits, 0 through 9.');
INSERT INTO snippets VALUES ('othercharsonly', '_errormessages', '%%fieldname%% contains invalid characters.');
INSERT INTO snippets VALUES ('passwordcharsonly', '_errormessages', '%%fieldname%% must contain only letters, numbers, or the symbols _ * $ @ ! # + -');
INSERT INTO snippets VALUES ('passwordfirstchar', '_errormessages', '%%fieldname%% must start with a letter or number.');
INSERT INTO snippets VALUES ('phonebadformat', '_errormessages', '%%fieldname%% must be a valid Phone Number.');
INSERT INTO snippets VALUES ('regexpbadformat', '_errormessages', '%%fieldname%% is invalid.');
INSERT INTO snippets VALUES ('required', '_errormessages', '%%fieldname%% is required.');
INSERT INTO snippets VALUES ('securityanswerbad', '_errormessages', 'The security answer you provided does not match our records. Please review your answer and try again.');
INSERT INTO snippets VALUES ('ssnbadformat', '_errormessages', '%%fieldname%% must be a valid Social Security Number.');
INSERT INTO snippets VALUES ('usernamecharsonly', '_errormessages', '%%fieldname%% must contain only letters, numbers, or the symbols _ * $ @ ! # + -');
INSERT INTO snippets VALUES ('usernamefirstchar', '_errormessages', '%%fieldname%% must start with a letter or number.');
INSERT INTO snippets VALUES ('uszipbadformat', '_errormessages', '%%fieldname%% must be a valid US ZIP code.');
INSERT INTO snippets VALUES ('visabadformat', '_errormessages', '%%fieldname%% must be a valid Visa card number.');
INSERT INTO snippets VALUES ('visamcbadformat', '_errormessages', '%%fieldname%% must be a valid Visa or MasterCard card number.');
INSERT INTO snippets VALUES ('can_states_long', '_common', 'AB|Alberta,BC|British Columbia,MB|Manitoba,NB|New Brunswick,NF|Newfoundland,NT|Northwest Territories,NS|Nova Scotia,ON|Ontario,PE|Prince Edward Island,QC|Quebec,SK|Saskatchewan,YT|Yukon');
INSERT INTO snippets VALUES ('can_states_short', '_common', 'AB,BC,MB,NB,NF,NS,NT,ON,PE,QC,SK,YT');
INSERT INTO snippets VALUES ('states_long', '_common', '%%snippet:usa_states_long:_common%%');
INSERT INTO snippets VALUES ('states_short', '_common', '%%snippet:usa_states_short:_common%%');
INSERT INTO snippets VALUES ('usa_states_long', '_common', 'AL|Alabama,AK|Alaska,AZ|Arizona,AR|Arkansas,CA|California,CO|Colorado,CT|Connecticut,DE|Delaware,DC|District of Columbia,FL|Florida,GA|Georgia,HI|Hawaii,ID|Idaho,IL|Illinois,IN|Indiana,IA|Iowa,KS|Kansas,KY|Kentucky,LA|Louisiana,ME|Maine,MD|Maryland,MA|Massachusetts,MI|Michigan,MN|Minnesota,MS|Mississippi,MO|Missouri,MT|Montana,NE|Nebraska,NV|Nevada,NH|New Hampshire,NJ|New Jersey,NM|New Mexico,NY|New York,NC|North Carolina,ND|North Dakota,OH|Ohio,OK|Oklahoma,OR|Oregon,PA|Pennsylvania,RI|Rhode Island,SC|South Carolina,SD|South Dakota,TN|Tennessee,TX|Texas,UT|Utah,VT|Vermont,VA|Virginia,WA|Washington,WV|West Virginia,WI|Wisconsin,WY|Wyoming');
INSERT INTO snippets VALUES ('usa_states_short', '_common', 'AK,AL,AR,AZ,CA,CO,CT,DC,DE,FL,GA,HI,IA,ID,IL,IN,KS,KY,LA,MA,MD,ME,MI,MN,MO,MS,MT,NC,ND,NE,NH,NJ,NM,NV,NY,OH,OK,OR,PA,RI,SC,SD,TN,TX,UT,VA,VT,WA,WI,WV,WY ');
INSERT INTO snippets VALUES ('clientsideheader', '_errormessages', 'The following problems were found:');
INSERT INTO snippets VALUES ('months_long', '_common', 'January,February,March,April,May,June,July,August,September,October,November,December');
INSERT INTO snippets VALUES ('months_short', '_common', 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec');
INSERT INTO snippets VALUES ('pci_password_change_message', '_common', 'Your password cannot match any of your 4 previous passwords, or any password used in the last 30 days.');
INSERT INTO snippets VALUES ('pci_password_change_message', '_errormessages', 'Password cannot match any of your 4 previous passwords, or any password used in the last 30 days.');
INSERT INTO snippets VALUES ('pci_password_message', '_errormessages', 'Password must be at least 8 characters and must contain at least 1 upper case character, 1 lower case character, and 1 numeric digit.');
INSERT INTO snippets VALUES ('pci_password_bad_words', '_regexp', 'fuck|ass|shit|dick|cunt|bitch|whore|pussy');
INSERT INTO snippets VALUES ('cardnumberbadformat', '_errormessages', '%%fieldname%% must be a valid credit card number.');
INSERT INTO snippets VALUES ('hexcolorbadformat', '_errormessages', '%%fieldname%% must be a valid hex color.');
INSERT INTO snippets VALUES ('greaterthanorequal', '_errormessages', '%%fieldname1%% must be greater than or equal to %%fieldname2%%.');
INSERT INTO snippets VALUES ('xor', '_errormessages', 'Either %%fieldname%% must contain a value but not both.');
INSERT INTO snippets VALUES ('ip_address', '_regexp', '^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
INSERT INTO snippets VALUES ('invalidchars', '_errormessages', '%%fieldname%% contains invalid characters.');
INSERT INTO snippets VALUES ('numericonly', '_errormessages', '%%fieldname%% must be a number.');
INSERT INTO snippets VALUES ('lessthan', '_errormessages', '%%fieldname1%% must be less than %%fieldname2%%.');
INSERT INTO snippets VALUES ('greaterthan', '_errormessages', '%%fieldname1%% must be greater than %%fieldname2%%.');
INSERT INTO snippets VALUES ('currencyonly', '_errormessages', '%%fieldname%% must be a valid currency amount.');
INSERT INTO snippets VALUES ('usphonebadformat', '_errormessages', '%%fieldname%% must be a valid US phone number.');
