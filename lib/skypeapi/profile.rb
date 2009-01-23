module SkypeAPI
  module Object
    class Profile < AbstractObject
      OBJECT_NAME = "PROFILE"
      
      def initialize(id=nil)
        super nil
      end
      
      def self.new
        super nil
      end
      
      def self.notified msg
        if msg =~ /^([^ ]+) (.*)$/m
          property = P2M[$1]
          value = V2O[property] ? V2O[property].call($2) : $2
          instance = new
          instance.notified instance, property,value #if @@instance[self][id]
          
          #p [property,value,instance,@notify]
          #if @notify[nil]
          #  @notify[nil][nil].call instance, property, value if @notify[nil][nil]
          #  @notify[nil][value].call instance, property if @notify[nil][value]
          #end
          #if @notify[property]
          #  @notify[property][nil].call instance, value if @notify[property][nil]
          #  @notify[property][value].call instance if @notify[property][value]
          #end
        end
      end
      
      getter :PSTNBalance, 'PSTN_BALANCE' do |str|
        str._int
      end
      getter :PSTNBalanceCurrency, 'PSTN_BALANCE_CURRENCY'
      getter :Fullname, 'FULLNAME'
      getter :Birthday, 'BIRTHDAY' do |yyyymmdd|
        (yyyymmdd =~ /(\d\d\d\d)(\d\d)(\d\d)/) ? Date.new($1.to_i,$2.to_i,$3.to_i) : nil
      end
      getter :Sex, 'SEX'
      getter :Languages, 'LANGUAGES' do |str|
        str.split(' ')
      end
      getter :Country, 'COUNTRY' do |str|
        str.empty? ? str : str.split(' ', 2)[0]
      end
      getter :IPCountry, 'IPCOUNTRY'
      getter :Province, 'PROVINCE'
      getter :City, 'CITY'
      getter :PhoneHome, 'PHONE_HOME'
      getter :PhoneOffice, 'PHONE_OFFICE'
      getter :PhoneMobile, 'PHONE_MOBILE'
      getter :Homepage, 'HOMEPAGE'
      getter :About, 'ABOUT'
      getter :MoodText, 'MOOD_TEXT'
      getter :RichMoodText, 'RICH_MOOD_TEXT'
      getter :Timezone, 'TIMEZONE' do |str|
        str._int
      end
      getter :CallApplyCF, 'CALL_APPLY_CF' do |str|
        str._flag
      end
      getter :CallNoanswerTimeout, 'CALL_NOANSWER_TIMEOUT' do |str|
        str._int
      end
      getter :CallForwardRules, 'CALL_FORWARD_RULES' do |str|
        cfs = str.split ' '
        cfs = cfs.map do |cf|
          cf = cf.split ','
          cf[2] = @@skypeApi.user(cf[2]) unless cf[2] =~ /^\+/
          [cf[0].to_i, cf[1].to_i, (cf[2] =~ /^\+/ ? cf[2] : @@skypeApi.user(cf[2]))]
        end
      end
      getter :CallSendToVM, 'CALL_SEND_TO_VM' do |str|
        str._flag
      end
      getter :SMSValidatedNumbers, 'SMS_VALIDATED_NUMBERS' do |str|
        str.split(', ')
      end
      
      def setFullname(name) invoke_set('FULLNAME', name); end
      def setBirthday(dateOrYear=nil, month=nil, day=nil)
        if dateOrYear.nil?
          val = ''
        else
          val = dateOrYear.class == Date ? dateOrYear.strftime('%Y%m%d') : sprintf("%04d%02d%02d",dateOrYear,month,day)
        end
        invoke_set('BIRTHDAY', val)
      end
      def setSex(sex) invoke_set('SEX', sex); end
      def setLanguages(*langs)
        invoke_set('LANGUAGES', langs.join(' '))
      end
      def setCountry(iso) invoke_set('COUNTRY', iso); end
      #def setIpcountry(val) invoke_set('IPCOUNTRY', val); end
      def setProvince(province) invoke_set('PROVINCE', province); end
      def setCity(city) invoke_set('CITY', city); end
      def setPhoneHome(numbers) invoke_set('PHONE_HOME', numbers); end
      def setPhoneOffice(numbers) invoke_set('PHONE_OFFICE', numbers); end
      def setPhoneMobile(numbers) invoke_set('PHONE_MOBILE', numbers); end
      def setHomepage(url) invoke_set('HOMEPAGE', url); end
      def setAbout(text) invoke_set('ABOUT', text); end
      def setMoodText(text) invoke_set('MOOD_TEXT', text); end
      def setRichMoodText(text) invoke_set('RICH_MOOD_TEXT', text); end
      def setTimezone(timezone) invoke_set('TIMEZONE', timezone); end
      def setCallApplyCF(flag)
        invoke_set('CALL_APPLY_CF', flag._str)
      end
      def setCallNoanswerTimeout(sec) invoke_set('CALL_NOANSWER_TIMEOUT', sec); end
      def setCallForwardRules(*rules)
        if rules[0] == nil
          invoke_set('CALL_FORWARD_RULES', '')
        else
          rules.map! do |rule|
            rule.join ','
          end
          rules = rules.join ' '
          invoke_set('CALL_FORWARD_RULES', rules)
        end
      end
      def setCallSendToVM(flag)
        invoke_set('CALL_SEND_TO_VM', flag._str)
      end
    end
  end
end
