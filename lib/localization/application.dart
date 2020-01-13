import 'dart:ui';

class Application {

  static final Application _application = Application._internal();      //calling named generative constructor

  factory Application() {                                     //Defining factory constructor
    return _application;
  }

  /*The _internal construction is just a name
  often given to constructors that are private
  to the class (the name is not required to be ._internal
  you can create a private constructor using any Class._someName construction).*/

  /*A generative constructor is a function that
  always returns a new instance of the class.
  Because of this, it does not utilize the return keyword*/

  Application._internal();    //Defining named generative constructor

  final List<String> supportedLanguages = [
    "English",
    "Spanish",
  ];

  final List<String> supportedLanguagesCodes = [
    "en",
    "es",
  ];

  //returns the list of supported Locales
  Iterable<Locale> supportedLocales() => supportedLanguagesCodes.map<Locale>((language) => Locale(language, ""));
  //function to be invoked when changing the language
  LocaleChangeCallback onLocaleChanged;
}

Application application = Application(); //application object of class Application is created

typedef void LocaleChangeCallback(Locale locale);
