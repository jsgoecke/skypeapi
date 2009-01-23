module SkypeAPI
  module Object
    class User < AbstractObject
      OBJECT_NAME = "USER"
      
      getter :Handle, 'HANDLE'
      getter :Fullname, 'FULLNAME'
      getter :Birthday,'BIRTHDAY' do |yyyymmdd|
        (yyyymmdd =~ /(\d\d\d\d)(\d\d)(\d\d)/) ? Date.new($1.to_i,$2.to_i,$3.to_i) : nil
      end
      getter :Sex, 'SEX'
      getter :Language, 'LANGUAGE' do |str|
        str.empty? ? str : str.split(' ',2)[0]
      end
      getter :Country, 'COUNTRY' do |str|
        str.empty? ? str : str.split(' ',2)[0]
      end
      getter :Province, 'PROVINCE'
      getter :City, 'CITY'
      getter :PhoneHome, 'PHONE_HOME'
      getter :PhoneOffice, 'PHONE_OFFICE'
      getter :PhoneMobile, 'PHONE_MOBILE'
      getter :Homepage, 'HOMEPAGE'
      getter :About, 'ABOUT'
      getter :HasCallEquipment, 'HASCALLEQUIPMENT' do |str|
        str._flag
      end
      getter :IsVideoCapable, 'IS_VIDEO_CAPABLE'  do |str|
        str._flag
      end
      getter :IsVoicemailCapable, 'IS_VOICEMAIL_CAPABLE' do |str|
        str._flag
      end
      getter :BuddyStatus, 'BUDDYSTATUS' do |str|
        str.to_i
      end
      getter :IsAuthorized, 'ISAUTHORIZED' do |str|
        str._flag
      end
      getter :IsBlocked, 'ISBLOCKED' do |str|
        str._flag
      end
      getter :OnlineStatus, 'ONLINESTATUS'
      #getter :skypeOut, 'SkypeOut'
      #getter :skypeMe, 'SKYPEME'
      getter :LastOnlineTimestamp, 'LASTONLINETIMESTAMP' do |str|
        if str.empty? then nil else Time.at(str.to_i) end
      end
      getter :CanLeaveVM, 'CAN_LEAVE_VM' do |str|
        str._flag
      end
      getter :SpeedDial, 'SPEEDDIAL' do |str|
        str#._int
      end
      getter :ReceivedAuthRequest, 'RECEIVEDAUTHREQUEST'
      getter :MoodText, 'MOOD_TEXT'
      getter :RichMoodText, 'RICH_MOOD_TEXT'
      getter :Aliases, 'ALIASES'
      getter :Timezone, 'TIMEZONE' do |str|
        str._int
      end
      getter :IsCFActive, 'IS_CF_ACTIVE' do |str|
        str._flag
      end
      getter :NrofAuthedBuddies, 'NROF_AUTHED_BUDDIES' do |str|
        str._int
      end
      getter :DisplayName, 'DISPLAYNAME'
      
      def getAvatar(filePath)
        invoke("GET USER #{@id} AVATAR 1 #{filePath}") =~ /^USER #{@id} AVATAR \d+ (.+)$/
        #if $1
        #  return $1
        #else
          return nil
        #end
      end
      notice :Avatar, 'AVATAR 1'
      
      def setBuddyStatus(statusCode, msg="")
        raise ArgumentErorr unless statusCode.to_i == 1 or statusCode.to_i == 2
        invoke_set('BUDDYSTATUS',"#{statusCode} #{msg}")
      end
      
      def setIsBlocked(flag) invoke_set('ISBLOCKED', flag._str); end
      
      def setIsAuthorized(flag) invoke_set('ISAUTHORIZED', flag._str); end
      
      def setSpeedDial(numbers) invoke_set('SPEEDDIAL', numbers); end
      
      def setDisplayName(name) invoke_set('DISPLAYNAME', name);end


      def addContactList msg=""
        val = invoke_set("BUDDYSTATUS","2 #{msg}")
        val == 2 or val == 3
      end
            
      def addedContactList?
        val = getBuddyStatus
        val == 3 or val == 2
      end
      
      def delContactList
        invoke_set("BUDDYSTATUS","1") == 1
      end
    end
  end
end
