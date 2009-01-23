require "forwardable.rb"
require "skypeapi/sharefunctions.rb"
require "skypeapi/object.rb"
require "skypeapi/version.rb"
require "skypeapi/user.rb"
require "skypeapi/profile.rb"
require "skypeapi/call.rb"
require "skypeapi/message.rb"
require "skypeapi/chat.rb"
require "skypeapi/chatmessage.rb"
require "skypeapi/chatmember.rb"
require "skypeapi/voicemail.rb"
require "skypeapi/sms.rb"
require "skypeapi/application.rb"
require "skypeapi/group.rb"
require "skypeapi/filetransfer.rb"
require "skypeapi/event.rb"
require "skypeapi/menuitem.rb"
require "skypeapi/os/etc.rb"

class SkypeAPIError < StandardError
  class Attach < SkypeAPIError; end
  class API < SkypeAPIError; end
  class NotImprement < SkypeAPIError; end
end

module SkypeAPI
  include SkypeAPI::Object
  extend Notify
  extend Get
  extend SkypeAPI::ShareFunctions
  
  P2M = Hash.new{|hash,key| hash[key] = key}
  V2O = Hash.new
  
  def self.init os=RUBY_PLATFORM.downcase
    unless @inited
      case os
      when /(mswin(?!ce))|(mingw)|(cygwin)|(bccwin)/
        require 'skypeapi/os/windows.rb'
        @os = SkypeAPI::OS::Windows.new
      when /(mac)|(darwin)/
        require 'skypeapi/os/mac.rb'
        @os = SkypeAPI::OS::Mac.new
      when /(linux)/
        require 'skypeapi/os/linux.rb'
        @os = SkypeAPI::OS::Linux.new
      else
        raise SkypeAPIError::NotImplementError,"#{os} is unknown or not support OS"
      end
      
      #SkypeAPI縺ｯ繝｢繧ｸ繝･繝ｼ繝ｫ縺ｮ縺溘ａ縺ｫ縲√ョ繝ｪ繧ｲ繝ｼ繧ｿ繝ｼ縺ｧ繧ｯ繝ｩ繧ｹ繝｡繧ｽ繝・ラ縺ｨ縺励※螳夂ｾｩ縲・
      #SkypeAPI逶ｴ荳九・繝｡繧ｽ繝・ラ縺ｯ蜈ｨ縺ｦ繧ｯ繝ｩ繧ｹ繝｡繧ｽ繝・ラ縺ｪ縺ｮ縺ｧ繧｢繧ｯ繧ｻ繧ｹ蜿ｯ閭ｽ.
      self.class.extend Forwardable
      self.class.def_delegators(:@os,
        :invoke,
        :add_event,
        :del_event,
        :get_event,
        :exist_event?,
        :attach,
        :attach_wait,
        :polling,
        :wait,
        :close
      )
      class << self
        alias addEvent add_event
        alias setEvent add_event
        alias delEvent del_event
        alias getEvent get_event
        alias existEvent? exist_event?
        alias attachWait attach_wait
      end
      
      #螟門・逕ｨ縲・
      #self.class.__send__(:define_method, :os, Proc.new{@os})
      
      @notify = Hash.new
      @os.add_notify nil, method(:notified)
      objectsInit
      
      @inited = true
    else
      #raise SkypeAPIError,'init at onece'
    end
  end
  
  def self.new
    init
    self
  end
  
  def self.os
    @os
  end
  
  def self.notified msg
    skypeProperty = nil
    propertyReg = '(?:' + [
      'CONTACTS FOCUSED',
      'RINGTONE 1 STATUS',
      'RINGTONE 1',
      '[^ ]+'
    ].join(')|(?:') + ')'
    
    if msg =~ /^(#{propertyReg}) (.+)$/m
      skypeProperty = $1; value = $2
      property = self::P2M[skypeProperty].to_s.downcase.to_sym if self::P2M[skypeProperty].class == Symbol
      value = self::V2O[skypeProperty].call value if self::V2O[skypeProperty]
      
      if @notify[nil]
        @notify[nil][nil].call property, value if @notify[nil][nil]
        @notify[nil][value].call property if @notify[nil][value]
      end
      if @notify[property]
        @notify[property][nil].call value if @notify[property][nil]
        @notify[property][value].call if @notify[property][value]
      end
    end
  end
  
  def self.objectsInit
    [User,Profile,Call,Message,Chat,ChatMessage,ChatMember,VoiceMail,SMS,Application,Group,FileTransfer,Event,MenuItem].each do |klass|
      @os.add_notify /^#{klass::OBJECT_NAME} (.+)$/m, klass.method(:notified)
    end
  end
  
  def self.User() User ;end
  
  def self.user(id) User.new(id) ; end
  
  def self.Call() Call ; end
  
  def self.call(id) Call.new(id) ; end
  
  def self.Profile() Profile.new nil ; end
  
  def self.profile() Profile.new nil ; end
  
  def self.Chat() Chat ; end
  
  def self.chat(id) Chat.new(id) ; end
  
  def self.ChatMessage() ChatMessage ; end
  
  def self.chatMessage(id) ChatMessage.new(id) ; end
  
  def self.ChatMember() ChatMember ; end
  
  def self.chatMember(id) ChatMember.new(id) ; end
  
  def self.Message() Message ; end
  
  def self.message(id) Message.new(id) ; end
  
  def self.VoiceMail() VoiceMail ; end
  
  def self.voiceMail(id)VoiceMail.new(id) ; end
  
  def self.SMS() SMS ; end
  
  def self.sms(id) SMS.new(id) ; end
  
  def self.Application() Application ; end
  
  def self.application(id) Application.new(id) ; end
  
  def self.Group() Group ; end
  
  def self.group(id) Group.new(id) ; end

  def self.FileTransfer() FileTransfer ; end
  
  def self.fileTransfer(id) FileTransfer.new(id) ; end
  
  def self.Event() Event ; end
  
  def self.event(id) Event.new(id) ; end
  
  def self.MenuItem() MenuItem ; end
  
  def self.menuItem(id) MenuItem.new(id) ; end
  
  #General
  
  getter :SkypeVersion, 'SKYPEVERSION'
  
  getter :CurrentUserHandle, 'CURRENTUSERHANDLE'
  
  getter :UserStatus, 'USERSTATUS'
  
  def self.setUserStatus(status) invoke_set "USERSTATUS", status ; end
  
  def self.getPrivilege(privilege) invoke_get("PRIVILEGE #{privilege}")._flag ; end
  notice :Privilege, 'PRIVILEGE'
  # privilege SkypeOut | SkypeIn | VoiceMail
  
  getter :PredictiveDialerCountry, 'PREDICTIVE_DIALER_COUNTRY'
  
  getter :Connstatus, 'CONNSTATUS'
  
  getter :AudioIn, 'AUDIO_IN'
  
  def self.setAudioIn(device) invoke_set "AUDIO_IN", device ; end  
  
  getter :AudioOut, 'AUDIO_OUT'
  
  def self.setAudioOut(device) invoke_set "AUDIO_OUT", device ; end
  
  getter :Ringer, 'RINGER'
  
  def self.setRinger(device) invoke_set("RINGER", device) ; end
  
  getter :Mute, 'MUTE' do |str|
    str._flag
  end
  
  def self.setMute(flag) invoke_set("MUTE", flag._swi) ;end
  
  def self.getAvatar(filePath, num=1) invoke_get("AVATAR #{num} #{filePath}") ; end
  notice :Avator, 'AVATOR'
  #?
  
  def self.setAvatar(filePath, idx="", num=1)
    invoke_set("AVATAR", "#{num} #{filePath}#{idx.empty? ? '' : ':'+idx.to_s}").split(' ')[1]
  end
  
  def self.getRingtone(id=1) invoke_get("RINGTONE #{id}") ; end
  
  def self.setRingtone(filePath, idx="", id=1) invoke_set("RINGTONE","#{id} #{filePath}:#{idx}") ; end
  
  notice :Ringtone, "RINGTONE 1" do |str|
    num, file = str.split(' ',2)
    return num.to_i, file
  end
  #?
  
  def self.getRingtoneStatus(id=1)
    invoke("GET RINGTONE #{id} STATUS") =~ /RINGTONE #{id} ((ON)|(OFF))/
    $2._flag
  end
  
  notice :RingtoneStatus, "RINGTONE 1 STATUS" do |str|
    str._flag
  end
  #?
  
  def self.setRingtoneStatus(flag, id=1)
    invoke("SET RINGTONE #{id} STATUS #{flag._swi}") =~ /RINGTONE #{id} ((ON)|(OFF))/
    $2._flag
  end
    
  getter :PCSpeaker, 'PCSPEAKER' do |str| 
    str._flag
  end
  
  def self.setPCSpeaker(flag) invoke_set("PCSPEAKER", flag._swi) ; end
  
  getter :AGC, 'AGC' do |str|
    str._flag
  end
  
  def self.setAGC(flag) invoke_set("AGC", flag._swi) ; end
  
  getter :AEC, 'AEC' do |str|
    str._flag
  end
  
  def self.setAEC(flag) invoke_set("AEC", flag._swi) ; end
  
  def self.resetIdleTimer() invoke("RESETIDLETIMER") == "RESETIDLETIMER" ; end
  notice :ResetIdleTimer, 'RESETIDLETIMER' #?
  
  getter :AutoAway ,'AUTOAWAY' do |str|
      str._flag
  end
  
  def self.setAutoAway(flag) invoke_set('AUTOAWAY', flag._swi) ; end
  
  getter :VideoIn, 'VIDEO_IN'
  
  def self.setVideoIn(device) invoke_set("VIDEO_IN", device) ; end
  
  def self.ping waitLimit=nil
    if waitLimit
      invoke_block "PING", waitLimit
    else
      invoke("PING") == "PONG"
    end
  end
  
  #UserInterFace
  def self.focus() invoke('FOCUS') == 'FOCUS' ; end
  
  def self.minimize() invoke('MINIMIZE') == 'MINIMIZE' ; end
  
  getter :WindowState, 'WINDOWSTATE'
  
  def self.setWindowState(state) invoke_set("WINDOWSTATE", state); end
  
  def self.open prop, *value
    "OPEN #{prop} #{value.join(' ')}".rstrip == invoke("OPEN #{prop} #{value.join(' ')}".rstrip)
  end
  
  def self.openVideoTest id=''
    open 'VIDEOTEST', id
  end
  
  def self.openVoiceMail id
    open 'VOICEMAIL', id
  end
  
  def self.openAddAFriend user=''
    open 'ADDAFRIEND', user.to_s
  end
  
  def self.openIM user, msg=''
    open 'IM', user.to_s, msg
  end
  
  def self.openChat chat
    open 'CHAT', chat
  end
  
  def self.openFileTransfer path=nil, *users
    open 'FILETRANSFER', "#{users.join(', ')}",path ? "IN #{path}" : ''
  end
  
  def self.openLiveTab
    open 'LIVETAB'
  end
  
  def self.openProfile
    open 'PROFILE'
  end
  
  def self.openUserInfo user
    open 'USERINFO', user.to_s
  end
  
  def self.openConference
    open 'CONFERENCE'
  end
  
  def self.openSearch
    open 'SEARCH'
  end
  
  def self.openOptions page=''
    open 'OPTIONS', page
  end
  
  def self.openCallHistory
    open 'CALLHISTORY'
  end
  
  def self.openContacts
    open 'CONTACTS'
  end
  
  def self.openDialPad
    open 'DIALPAD'
  end
  
  def self.openSendContacts *users
    open 'SENDCONTACTS', users.join(' ')
  end
  
  def self.openBlockedUsers
    open 'BLOCKEDUSERS'
  end
  
  def self.openImportContacts
    open 'IMPORTCONTACTS'
  end
   
  def self.openGettingStarted
    open 'GETTINGSTARTED'
  end
  
  def self.openAuthorization user
    open 'AUTHORIZATION', user
  end
  
  def self.BTNPressed key
    invoke_echo "BTN_PRESSED #{key}"
  end
  
  def self.BTNReleased key
    invoke_echo "BTN_RELEASED #{key}"
  end
  
  getter :ContactsFocused, 'CONTACTS_FOCUSED' do |str|
    user str
  end
  #nitify?
  
  getter :UILanguage, 'UI_LANGUAGE'
  
  def self.setUILanguage(lang) invoke_set("UI_LANGUAGE", lang); end
  
  getter :WallPaper, 'WALLPAPER'
  
  def self.setWallPaper(filePath) invoke_set('WALLPAPER', filePath) ; end
  
  getter :SilentMode, 'SILENT_MODE' do |str|
    str._flag
  end
  
  def self.setSilentMode(flag) invoke_set('SILENT_MODE', flag._swi) ; end
  
  #Search
  
  def self.search prop, preffix=prop, val=''
    ret = invoke "SEARCH #{prop} #{val}"
    ret =~ /^#{preffix} (.+)$/
    if $1
      $1.split(', ')
    else
      []
    end
  end
  
  def self.searchFriends
    search('FRIENDS','USERS').map do |handle|
      user(handle)
    end
  end
  
  def self.searchUsers target
    search('USERS','USERS',target).map do |handle|
      user(handle)
    end
  end
  
  def self.searchCalls target
    search('CALLS','CALLS',target).map do |id|
      call(id)
    end
  end
  
  def self.searchActiveCalls
    search('ACTIVECALLS','CALLS').map do |id|
      call(id)
    end
  end
  
  def self.searchMissedCalls
    search('MISSEDCALLS','CALLS').map do |id|
      call(id)
    end
  end
  
  def self.searchSMSs
    search('SMSS').map do |id|
      sms(id)
    end
  end
  
  def self.searchMissedSMSs
    search('MISSEDSMSS','SMSS').map do |id|
      sms(id)
    end
  end
  
  def self.searchVoiceMails
    search('VOICEMAILS').map do |id|
      voiceMail(id)
    end
  end
    
  def self.searchMissedVoiceMails
    search('MISSEDVOICEMAILS','VOICEMAILS').map do |id|
      voiceMail id
    end
  end
    
  def self.searchMessages(target='')
    search('MESSAGES', 'MESSAGES', target).map do |id|
      message id
    end
  end
  
  def self.searchMissedMessages
    search('MISSEDMESSAGES','MESSAGES').map do |id|
      message id
    end
  end
  
  def self.searchChats
    search('CHATS').map do |id|
      chat id
    end
  end
  
  def self.searchActiveChats
    search('ACTIVECHATS','CHATS').map do |id|
      chat id
    end
  end
  
  def self.searchMissedChats
    search('MISSEDCHATS','CHATS').map do |id|
      chat id
    end
  end

  def self.searchRecentChats
    search('RECENTCHATS','CHATS').map do |id|
      chat id
    end
  end
  
  def self.searchBookMarkedChats
    search('BOOKMARKEDCHATS','CHATS').map do |id|
      chat id
    end
  end
  
  def self.searchChatMessages target=''
    search('CHATMESSAGES','CHATMESSAGES', target).map do |id|
      chatMessage id
    end
  end
  
  def self.searchMissedChatMessages
    search('MISSEDCHATMESSAGES','CHATMESSAGES').map do |id|
      chatMessage id
    end
  end
  
  def self.searchUsersWaitingMyAuthorization
    search('USERSWAITINGMYAUTHORIZATION','USERS').map do |handle|
      user handle
    end
  end
  
  def self.searchGroups type=''
    search('GROUPS','GROUPS',type).map do |id|
      group id
    end
  end
  
  def self.searchFileTransfers
    search('FILETRANSFERS').map do |id|
      fileTransfer id
    end
  end
  
  def self.searchActiveFileTransfers
    search('ACTIVEFILETRANSFERS','FILETRANSFERS').map do |id|
      fileTransfer id
    end
  end
  
  #History
  
  def self.clearChatHistory() invoke('CLEAR CHATHISTORY') == 'CLEAR CHATHISTORY' ; end 
  
  def self.clearVoiceMailHistory() invoke('CLEAR VOICEMAILHISTORY') == 'CLEAR VOICEMAILHISTORY' ; end
  
  def self.clearCallHistory(type, handle='')
    invoke("CLEAR CALLHISTORY #{type} #{handle}") == "CLEAR CALLHISTORY #{type} #{handle}".rstrip
  end
  
  notice :CallHistoryChanged, 'CALLHISTORYCHANGED'
  notice :IMHistoryChanged, 'IMHISTORYCHANGED'
  
  #private :notified, :open, :search
  #obs
  
  #def openApplication appName
  #  return A2A.new(appName,self)
  #end
  
  #def openExtendApplication appName
  #  return A2AEx.new(appName,self)
  #end
end
