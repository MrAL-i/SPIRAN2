--Begin supergrpup.lua
--Check members #Add supergroup
local function check_member_super(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if success == 0 then
	send_large_msg(receiver, "⚠️اول مرا ادمین کنید.⚠️")
  end
  for k,v in pairs(result) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- SuperGroup configuration
      data[tostring(msg.to.id)] = {
        group_type = 'SuperGroup',
		long_id = msg.to.peer_id,
		moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.title, '_', ' '),
		  lock_arabic = '🔓',
		  lock_link = "🔓",
		  lock_bots = "🔒",
		  lock_tags = "🔓",
		  lock_emoji = "🔓",
		  lock_username = "🔓",

		  lock_media = "🔓",
          flood = '🔒',
		  lock_spam = '🔒',
		  lock_sticker = '🔓',
		  member = '🔓',
		  public = '🔓',
		  lock_rtl = '🔓',
		  lock_tgservice = '🔒',
		  lock_contacts = '🔓',
		  strict = '🔓'
        }
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
	  local text = '🔱سوپرگروه با موفقیت اضافه شد.🔱'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Check Members #rem supergroup
local function check_member_superrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result) do
    local member_id = v.id
    if member_id ~= our_id then
	  -- Group configuration removal
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
	  local text = '❌SuperGroup has been removed❌'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Function to Add supergroup
local function superadd(msg)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_super,{receiver = receiver, data = data, msg = msg})
end

--Function to remove supergroup
local function superrem(msg)
	local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_superrem,{receiver = receiver, data = data, msg = msg})
end

--Get and output admins and bots in supergroup
local function callback(cb_extra, success, result)
local i = 1
local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
local member_type = cb_extra.member_type
local text = member_type.." for "..chat_name..":\n"
for k,v in pairsByKeys(result) do
if not v.first_name then
	name = " "
else
	vname = v.first_name:gsub("‮", "")
	name = vname:gsub("_", " ")
	end
		text = text.."\n"..i.." - "..name.."["..v.peer_id.."]"
		i = i + 1
	end
    send_large_msg(cb_extra.receiver, text)
end

local function callback_clean_bots (extra, success, result)
	local msg = extra.msg
	local receiver = 'channel#id'..msg.to.id
	local channel_id = msg.to.id
	for k,v in pairs(result) do
		local bot_id = v.peer_id
		kick_user(bot_id,channel_id)
	end
end

--Get and output info about supergroup
local function callback_info(cb_extra, success, result)
local title ="اطلاعات برای سوپرگروه: ["..result.title.."]\n\n"
local admin_num = "تعداد ادمین ها: "..result.admins_count.."\n"
local user_num = "تعداد اعضا: "..result.participants_count.."\n"
local kicked_num = "تعداد افراد کیک شده: "..result.kicked_count.."\n"
local channel_id = "آیدی: "..result.peer_id.."\n"
if result.username then
	channel_username = "Username: @"..result.username
else
	channel_username = ""
end
local text = title..admin_num..user_num..kicked_num..channel_id..channel_username
    send_large_msg(cb_extra.receiver, text)
end

--Get and output members of supergroup
local function callback_who(cb_extra, success, result)
local text = "Members for "..cb_extra.receiver
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		username = " @"..v.username
	else
		username = ""
	end
	text = text.."\n"..i.." - "..name.." "..username.." [ "..v.peer_id.." ]\n"
	--text = text.."\n"..username
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/"..cb_extra.receiver..".txt", ok_cb, false)
	post_msg(cb_extra.receiver, text, ok_cb, false)
end

--Get and output list of kicked users for supergroup
local function callback_kicked(cb_extra, success, result)
--vardump(result)
local text = "Kicked Members for SuperGroup "..cb_extra.receiver.."\n\n"
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		name = name.." @"..v.username
	end
	text = text.."\n"..i.." - "..name.." [ "..v.peer_id.." ]\n"
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", ok_cb, false)
	--send_large_msg(cb_extra.receiver, text)
end

--Begin supergroup locks
local function lock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == '🔒' then
    local text = 'قفل لینک از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_link'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل لینک فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == '🔓' then
    local text = 'قفل لینک فعال نیست.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_link'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل لینک غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_leave(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_leave_lock = data[tostring(target)]['settings']['lock_leave']
  if group_leave_lock == '🔒' then
    local text = 'قفل خارج شدن از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_leave'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل خارج شدن فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_leave(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_leave_lock = data[tostring(target)]['settings']['lock_leave']
  if group_leave_lock == '🔓' then
    local text = 'قفل خارج شدن فعال نیست.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_leave'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل خارج شدن غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_all_lock = data[tostring(target)]['settings']['lock_all']
  if group_all_lock == '🔒' then
    local text = 'تمامی قفل ها از قبل فعال بودند.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_all'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'تمامی قفل ها فعال شدند.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_all_lock = data[tostring(target)]['settings']['lock_all']
  if group_all_lock == '🔓' then
    local text = 'تمامی قفل ها غیرفعال هستند.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_all'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'تمامی قفل ها غیرفعال شدند.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_english(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_english_lock = data[tostring(target)]['settings']['lock_english']
  if group_english_lock == '🔒' then
    local text = 'قفل انگلیسی از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_english'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل انگلیسی فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_english(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_english_lock = data[tostring(target)]['settings']['lock_english']
  if group_english_lock == '🔓' then
    local text = 'قفل انگلیسی غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_english'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل انگلیسی غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_badword(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_badword_lock = data[tostring(target)]['settings']['lock_badword']
  if group_badword_lock == '🔒' then
    local text = 'قفل حروف بد از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_badword'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل حروف بد فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_badword(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_badword_lock = data[tostring(target)]['settings']['lock_badword']
  if group_badword_lock == '🔓' then
    local text = 'قفل حروف بد غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_badword'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل حروف بد غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_number(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_number_lock = data[tostring(target)]['settings']['lock_number']
  if group_number_lock == '🔒' then
    local text = 'قفل اعداد از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_number'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل اعداد فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_number(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_number_lock = data[tostring(target)]['settings']['lock_number']
  if group_number_lock == '🔓' then
    local text = 'قفل اعداد غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_number'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل اعداد غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_operator(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_operator_lock = data[tostring(target)]['settings']['lock_operator']
  if group_operator_lock == '🔒' then
    local text = 'قفل نام های اوپراتورها از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_operator'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل نام های اوپراتورها فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_operator(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_operator_lock = data[tostring(target)]['settings']['lock_operator']
  if group_operator_lock == '🔓' then
    local text = 'قفل نام های اوپراتورها غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_operator'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل نام های اوپراتورها غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_tags(msg, data, target)
  if not is_owner(msg) then
    return
  end
  local group_tag_lock = data[tostring(target)]['settings']['lock_tags']
  if group_tag_lock == '🔒' then
    local text = 'قفل تگ از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_tags'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل تگ فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_tags(msg, data, target)
  if not is_owner(msg) then
    return
  end
  local group_tag_lock = data[tostring(target)]['settings']['lock_tags']
  if group_tag_lock == '🔓' then
    local text = 'قفل تگ غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_tags'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل تگ غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_reply(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_reply_lock = data[tostring(target)]['settings']['lock_reply']
  if group_reply_lock == '🔒' then
    local text = 'قفل ریپلای از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_reply'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل ریپلای فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_reply(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_reply_lock = data[tostring(target)]['settings']['lock_reply']
  if group_reply_lock == '🔓' then
    local text = 'قفل ریپلای غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_reply'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل ریپلای غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  if group_fwd_lock == '🔒' then
    local text = 'قفل فوروارد از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_fwd'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل فوروارد فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  if group_fwd_lock == '🔓' then
    local text = 'قفل فوروارد غیرفعال است🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_fwd'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل فوروارد غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_join(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_join_lock = data[tostring(target)]['settings']['lock_join']
  if group_join_lock == '🔒' then
    local text = 'قفل ورود از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_join'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل ورود فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_join(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_join_lock = data[tostring(target)]['settings']['lock_join']
  if group_join_lock == '🔓' then
    local text = 'قفل ورود غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_join'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل ورود غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_emoji(msg, data, target)
  if not is_owner(msg) then
    return 
  end
  local group_emoji_lock = data[tostring(target)]['settings']['lock_emoji']
  if group_emoji_lock == '🔒' then
    local text = 'قفل شکلک ویا اموجی از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_emoji'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل اوجی فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_emoji(msg, data, target)
  if not is_owner(msg) then
    return 
  end
  local group_emoji_lock = data[tostring(target)]['settings']['lock_emoji']
  if group_emoji_lock == '🔓' then
    local text = 'قفل اموجی غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_emoji'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل اوجی غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_username(msg, data, target)
  if not is_owner(msg) then
    return 
  end
  local group_username_lock = data[tostring(target)]['settings']['lock_username']
  if group_username_lock == '🔒' then
    local text = 'قفل نام کاربری و یا یوزرنیم از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_username'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل یوزرنیم فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_username(msg, data, target)
  if not is_owner(msg) then
    return 
  end
  local group_username_lock = data[tostring(target)]['settings']['lock_username']
  if group_username_lock == '🔓' then
    local text = 'قفل یوزرنیم غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_username'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل یوزرنیم غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_media(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_media_lock = data[tostring(target)]['settings']['lock_media']
  if group_media_lock == '🔒' then
    local text = 'قفل رسانه ها از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_media'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل رسانه ها فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_media(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_media_lock = data[tostring(target)]['settings']['lock_media']
  if group_media_lock == '🔓' then
    local text = 'قفل رسانه ها غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_media'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل رسانه ها غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_bots(msg, data, target)
  if not is_owner(msg) then
    return
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == '🔒' then
    local text = 'قفل افزودن ربات از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_bots'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل افزودن ربات فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_bots(msg, data, target)
  if not is_owner(msg) then
    return
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == '🔓' then
    local text = 'قفل افزودن ربات غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_bots'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل افزودن ربات غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  if not is_owner(msg) then
    return "فقط صاحبان!"
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == '🔒' then
    local text = 'قفل اسپم از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_spam'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل اسپم فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == '🔓' then
    local text = 'قفل اسپم غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_spam'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل اسپم غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == '🔒' then
    local text = 'قفل فلود از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['flood'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل فلود فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == '🔓' then
    local text = 'قفل فلود غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['flood'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل فلود غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == '🔒' then
    local text = 'قفل عربی و فارسی از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_arabic'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل عربی فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == '🔓' then
    local text = 'قفل عربی و فارسی غیرفعال است.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_arabic'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل عربی و فارسی غیرفعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == '🔒' then
    local text = 'قفل افراد از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_member'] = '🔒'
    save_data(_config.moderation.data, data)
  end
  local text = 'قفل افراد فعال شد.🔒'
  return reply_msg(msg.id, text, ok_cb, false)
end

local function unlock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == '🔓' then
    local text = 'قفل افراد غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_member'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل افراد غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == '🔒' then
    local text = 'قفل کارکتر آر تی ال از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_rtl'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل کارکتر آر تی ال فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == '🔓' then
    local text = 'قفل کارکتر آر تی ال غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_rtl'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل کارکتر آر تی ال غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == '🔒' then
    local text = 'قفل سرویس تیجی از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_tgservice'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل سرویس تیجی فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == '🔓' then
    local text = 'قفل سرویس تیجی غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_tgservice'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل سرویس تیجی غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == '🔒' then
    local text = 'قفل استیکر از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_sticker'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل استیکر فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == '🔓' then
    local text = 'قفل استیکر غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_sticker'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'قفل استیکر غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function lock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == '🔒' then
    local text = 'قفل مخاطبین از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_contacts'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'قفل مخاطبین فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == '🔓' then
    local text = 'قفل مخاطبین غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_contacts'] = '❌'
    save_data(_config.moderation.data, data)
    local text = 'قفل مخاطبین غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function enable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == '🔒' then
    local text = 'تنظیمات سخت گیرانه از قبل فعال بود.🔐'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['strict'] = '🔒'
    save_data(_config.moderation.data, data)
    local text = 'تنظیمات سخت گیرانه فعال شد.🔒'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function disable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == '🔓' then
    local text = 'تنظیمات سخت گیرانه غیرفعال است.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['strict'] = '🔓'
    save_data(_config.moderation.data, data)
    local text = 'تنظیمات سخت گیرانه غیرفعال شد.🔓'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end
--End supergroup locks

--'Set supergroup rules' function
local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  local text = 'قوانین سوپرگروه تنطیم شد.'
end

--'Get supergroup rules' function
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    local text = 'قانونی موجود نیست.'
	return reply_msg(msg.id, text, ok_cb, false)
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  local group_name = data[tostring(msg.to.id)]['settings']['set_name']
  local rules = group_name..' قوانین:\n\n'..rules:gsub("/n", " ")
  return rules
end

--Set supergroup to public or not public function
local function set_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return "فقط برای مدیران!"
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == '🔒' then
    local text = 'گروه از قبل قابل مشاهده بود.'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['public'] = '🔒'
    save_data(_config.moderation.data, data)
  end
  local text = 'سوپرگروه قابل مشاهده شد.'
  return reply_msg(msg.id, text, ok_cb, false)
end

local function unset_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == '🔓' then
    local text = 'گروه قابل مشاهده نیست'
	return reply_msg(msg.id, text, ok_cb, false)
  else
    data[tostring(target)]['settings']['public'] = '🔓'
	data[tostring(target)]['long_id'] = msg.to.long_id
    save_data(_config.moderation.data, data)
    local text = 'سوپرگروه از قابل مشاهده بودن خارج شد.'
	return reply_msg(msg.id, text, ok_cb, false)
  end
end

--Show supergroup settings; function
function show_supergroup_settingsmod(msg, target)
 	if not is_momod(msg) then
    	return
  	end
	local data = load_data(_config.moderation.data)
    if data[tostring(target)] then
     	if data[tostring(target)]['settings']['flood_msg_max'] then
        	NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
        	print('custom'..NUM_MSG_MAX)
      	else
        	NUM_MSG_MAX = 5
      	end
    end
	local bots_protection = "🔒"
    if data[tostring(msg.to.id)]['settings']['lock_bots'] then
     bots_protection = data[tostring(msg.to.id)]['settings']['lock_bots']
    end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['public'] then
			data[tostring(target)]['settings']['public'] = '🔓'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_rtl'] then
			data[tostring(target)]['settings']['lock_rtl'] = '🔓'
		end
end
      if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tgservice'] then
			data[tostring(target)]['settings']['lock_tgservice'] = '🔓'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_member'] then
			data[tostring(target)]['settings']['lock_member'] = '🔓'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tags'] then
			data[tostring(target)]['settings']['lock_tags'] = '🔓'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_join'] then
			data[tostring(target)]['settings']['lock_join'] = '🔓'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_leave'] then
			data[tostring(target)]['settings']['lock_leave'] = '🔓'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_all'] then
			data[tostring(target)]['settings']['lock_all'] = '🔓'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_english'] then
			data[tostring(target)]['settings']['lock_english'] = '🔓'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_badword'] then
			data[tostring(target)]['settings']['lock_badword'] = '🔓'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_number'] then
			data[tostring(target)]['settings']['lock_number'] = '🔓'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_operator'] then
			data[tostring(target)]['settings']['lock_operator'] = '🔓'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_reply'] then
			data[tostring(target)]['settings']['lock_reply'] = '🔓'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_contacts'] then
			data[tostring(target)]['settings']['lock_contacts'] = '🔓'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_fwd'] then
			data[tostring(target)]['settings']['lock_fwd'] = '🔓'
		end
end
      if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_emoji'] then
			data[tostring(target)]['settings']['lock_emoji'] = '🔓'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_username'] then
			data[tostring(target)]['settings']['lock_username'] = '🔓'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_media'] then
			data[tostring(target)]['settings']['lock_media'] = '🔓'
		end
	end
  local settings = data[tostring(target)]['settings']
  local chat_id = msg.to.id
  local text = "➖➖➖➖➖➖➖➖➖➖\n🔧SuperGroup settings🔧\n➖➖➖➖➖➖➖➖➖➖\n💠قفل لینک : "..settings.lock_link.."\n💠قفل فلود : "..settings.flood.."\n💠قفل اسپم : "..settings.lock_spam.."\n💠قفل تگ : "..settings.lock_tags.."\n💠قفل ریپلای : "..settings.lock_reply.."\n💠قفل فوروارد : "..settings.lock_fwd.."\n💠قفل ورود : "..settings.lock_join.."\n💠قفل اموجی : "..settings.lock_emoji.."\n💠قفل مخاطبین : "..settings.lock_contacts.."\n💠قفل یوزرنیم : "..settings.lock_username.."\n💠قفل رسانه ها : "..settings.lock_media.."\n💠قفل ربات ها : "..settings.lock_bots.."\n💠قفل عربی و فارسی: "..settings.lock_arabic.."\n💠قفل افراد : "..settings.lock_member.."\n💠قفل کارکتر آر تی ال : "..settings.lock_rtl.."\n💠قفل انگلیسی : "..settings.lock_english.."\n💠قفل سرویس تیجی : "..settings.lock_tgservice.."\n💠قفل استیکر : "..settings.lock_sticker.."\n💠قفل اوپراتور : "..settings.lock_operator.."\n💠قفل اعداد : "..settings.lock_number.."\n💠قفل حروف بد : "..settings.lock_badword.."\n💠قفل خروج : "..settings.lock_leave.."\n➖➖➖➖➖➖➖➖➖➖\n⚙تنظیمات بیشتر⚙\n➖➖➖➖➖➖➖➖➖➖\n📍حساسیت فلود : "..NUM_MSG_MAX.."\n📍قابل مشاهده بودن : "..settings.public.."\n📍تنظیمات سخت گیرانه : "..settings.strict.."\n📍قفل همه : "..settings.lock_all.."\n➖➖➖➖➖➖➖➖➖➖\n⚙تنظیمات سایلنت⚙\n➖➖➖➖➖➖➖➖➖➖\n"..mutes_list(chat_id).."\n➖➖➖➖➖➖➖➖➖➖\nتوسط >>@SPIRAN_CHANNEL<<\nکلیه حقوق محفوظ است"  return reply_msg(msg.id, text, ok_cb, false)
end

local function promote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' در حال حاظر یک مدیر است.')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function demote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' یک مدیر نیست.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
end

local function promote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return send_large_msg(receiver, 'سوپرگروه اضافه نشده است.')
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' در حال حاظر یک مدیر است.')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' ترفیع یافت.')
end

local function demote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'گروه اضافه نشده است.')
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' یک مدیر نیست.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' تنزل یافت')
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "groups"
  if not data[tostring(groups)][tostring(msg.to.id)] then
    return 'SuperGroup is not added.'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then
    return 'هیچ مدیری در این گروه وجود ندارد.'
  end
  local i = 1
  local message = '\nList of moderators for ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message ..i..' - '..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end

-- Start by reply actions
function get_message_callback(extra, success, result)
	local get_cmd = extra.get_cmd
	local msg = extra.msg
	local data = load_data(_config.moderation.data)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
    if get_cmd == "id" and not result.action then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for: ["..result.from.peer_id.."]")
		id1 = send_large_msg(channel, result.from.peer_id)
	elseif get_cmd == 'id' and result.action then
		local action = result.action.type
		if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
			if result.action.user then
				user_id = result.action.user.peer_id
			else
				user_id = result.peer_id
			end
			local channel = 'channel#id'..result.to.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id by service msg for: ["..user_id.."]")
			id1 = send_large_msg(channel, user_id)
		end
    elseif get_cmd == "idfrom" then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for msg fwd from: ["..result.fwd_from.peer_id.."]")
		id2 = send_large_msg(channel, result.fwd_from.peer_id)
    elseif get_cmd == 'channel_block' and not result.action then
		local member_id = result.from.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "خارج شدن به وسیله دستور kickme.")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "شما نمی توانید صاحب گروه و ادمین ها را کیک کنید.")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "شما نمی توانید دیگر ادمین ها را کیک کنید.")
    end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply")
		kick_user(member_id, channel_id)
	elseif get_cmd == 'channel_block' and result.action and result.action.type == 'chat_add_user' then
		local user_id = result.action.user.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "خارج شدن به وسیله دستور kickme.")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "شما نمی توانید صاحب گروه و ادمین ها را کیک کنید.")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "شما نمی توانید دیگر ادمین ها را کیک کنید.")
    end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply to sev. msg.")
		kick_user(user_id, channel_id)
	elseif get_cmd == "del" then
		delete_msg(result.id, ok_cb, false)
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] deleted a message by reply")
	elseif get_cmd == "تنظیم ادمین" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		channel_set_admin(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." set as an admin"
		else
			text = "[ "..user_id.." ]ادمین شد."
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..user_id.."] as admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "تنزل ادمین" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		if is_admin2(result.from.peer_id) then
			return send_large_msg(channel_id, "You can't demote global admins!")
		end
		channel_demote(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." has been demoted from admin"
		else
			text = "[ "..user_id.." ] has been demoted from admin"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted: ["..user_id.."] from admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "تنظیم صاحب" then
		local group_owner = data[tostring(result.to.peer_id)]['set_owner']
		if group_owner then
		local channel_id = 'channel#id'..result.to.peer_id
			if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
				local user = "user#id"..group_owner
				channel_demote(channel_id, user, ok_cb, false)
			end
			local user_id = "user#id"..result.from.peer_id
			channel_set_admin(channel_id, user_id, ok_cb, false)
			data[tostring(result.to.peer_id)]['set_owner'] = tostring(result.from.peer_id)
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..result.from.peer_id.."] as owner by reply")
			if result.from.username then
				text = "@"..result.from.username.." [ "..result.from.peer_id.." ] added as owner"
			else
				text = "[ "..result.from.peer_id.." ] added as owner"
			end
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "ترفیع" then
		local receiver = result.to.peer_id
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
		if result.from.username then
			member_username = '@'.. result.from.username
		end
		local member_id = result.from.peer_id
		if result.to.peer_type == 'channel' then
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted mod: @"..member_username.."["..result.from.peer_id.."] by reply")
		promote2("channel#id"..result.to.peer_id, member_username, member_id)
	    --channel_set_mod(channel_id, user, ok_cb, false)
		end
	elseif get_cmd == "تنزل" then
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
    if result.from.username then
		member_username = '@'.. result.from.username
    end
		local member_id = result.from.peer_id
		--local user = "user#id"..result.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted mod: @"..member_username.."["..user_id.."] by reply")
		demote2("channel#id"..result.to.peer_id, member_username, member_id)
		--channel_demote(channel_id, user, ok_cb, false)
	elseif get_cmd == 'mute_user' then
		if result.service then
			local action = result.action.type
			if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
				if result.action.user then
					user_id = result.action.user.peer_id
				end
			end
			if action == 'chat_add_user_link' then
				if result.from then
					user_id = result.from.peer_id
				end
			end
		else
			user_id = result.from.peer_id
		end
		local receiver = extra.receiver
		local chat_id = msg.to.id
		print(user_id)
		print(chat_id)
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, "["..user_id.."] removed from the muted user list")
		elseif is_admin1(msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] added to the muted user list")
		end
	end
end
-- End by reply actions

--By ID actions
local function cb_user_info(extra, success, result)
	local receiver = extra.receiver
	local user_id = result.peer_id
	local get_cmd = extra.get_cmd
	local data = load_data(_config.moderation.data)
	--[[if get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		channel_set_admin(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." ✅ادمین شد.✅"
		else
			text = "[ "..result.peer_id.." ] ✅ادمین شد.✅"
		end
			send_large_msg(receiver, text)]]
	if get_cmd == "demoteadmin" then
		if is_admin2(result.peer_id) then
			return send_large_msg(receiver, "⚠️شما نمی توانید مدیران جهانی را برکنار کنید.⚠️")
		end
		local user_id = "user#id"..result.peer_id
		channel_demote(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." ✅از ادمینی برکنار شد.✅"
			send_large_msg(receiver, text)
		else
			text = "[ "..result.peer_id.." ] ✅از ادمینی برکنار شد.✅"
			send_large_msg(receiver, text)
		end
	elseif get_cmd == "ترفیع" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		promote2(receiver, member_username, user_id)
	elseif get_cmd == "تنزل" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		demote2(receiver, member_username, user_id)
	end
end

-- Begin resolve username actions
local function callbackres(extra, success, result)
  local member_id = result.peer_id
  local member_username = "@"..result.username
  local get_cmd = extra.get_cmd
	if get_cmd == "res" then
		local user = result.peer_id
		local name = string.gsub(result.print_name, "_", " ")
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user..'\n'..name)
		return user
	elseif get_cmd == "ایدی" then
		local user = result.peer_id
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user)
		return user
  elseif get_cmd == "دعوت" then
    local receiver = extra.channel
    local user_id = "user#id"..result.peer_id
    channel_invite(receiver, user_id, ok_cb, false)
	--[[elseif get_cmd == "channel_block" then
		local user_id = result.peer_id
		local channel_id = extra.channelid
    local sender = extra.sender
    if member_id == sender then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
		if is_momod2(member_id, channel_id) and not is_admin2(sender) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		kick_user(user_id, channel_id)
	elseif get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		channel_set_admin(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been set as an admin"
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "setowner" then
		local receiver = extra.channel
		local channel = string.gsub(receiver, 'channel#id', '')
		local from_id = extra.from_id
		local group_owner = data[tostring(channel)]['set_owner']
		if group_owner then
			local user = "user#id"..group_owner
			if not is_admin2(group_owner) and not is_support(group_owner) then
				channel_demote(receiver, user, ok_cb, false)
			end
			local user_id = "user#id"..result.peer_id
			channel_set_admin(receiver, user_id, ok_cb, false)
			data[tostring(channel)]['set_owner'] = tostring(result.peer_id)
			save_data(_config.moderation.data, data)
			savelog(channel, name_log.." ["..from_id.."] set ["..result.peer_id.."] as owner by username")
		if result.username then
			text = member_username.." [ "..result.peer_id.." ] added as owner"
		else
			text = "[ "..result.peer_id.." ] added as owner"
		end
		send_large_msg(receiver, text)
  end]]
	elseif get_cmd == "ترفیع" then
		local receiver = extra.channel
		local user_id = result.peer_id
		--local user = "user#id"..result.peer_id
		promote2(receiver, member_username, user_id)
		--channel_set_mod(receiver, user, ok_cb, false)
	elseif get_cmd == "تنزل" then
		local receiver = extra.channel
		local user_id = result.peer_id
		local user = "user#id"..result.peer_id
		demote2(receiver, member_username, user_id)
	elseif get_cmd == "تنزل ادمین" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		if is_admin2(result.peer_id) then
			return send_large_msg(channel_id, "⚠️You can't demote global admins!⚠️")
		end
		channel_demote(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." ✅has been demoted from admin✅"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." ✅has been demoted from admin✅"
			send_large_msg(channel_id, text)
		end
		local receiver = extra.channel
		local user_id = result.peer_id
		demote_admin(receiver, member_username, user_id)
	elseif get_cmd == 'mute_user' then
		local user_id = result.peer_id
		local receiver = extra.receiver
		local chat_id = string.gsub(receiver, 'channel#id', '')
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] ✅removed from muted user list✅")
		elseif is_owner(extra.msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] ✅added to muted user list✅")
		end
	end
end
--End resolve username actions

--Begin non-channel_invite username actions
local function in_channel_cb(cb_extra, success, result)
  local get_cmd = cb_extra.get_cmd
  local receiver = cb_extra.receiver
  local msg = cb_extra.msg
  local data = load_data(_config.moderation.data)
  local print_name = user_print_name(cb_extra.msg.from):gsub("‮", "")
  local name_log = print_name:gsub("_", " ")
  local member = cb_extra.username
  local memberid = cb_extra.user_id
  if member then
    text = 'No user @'..member..' in this SuperGroup.'
  else
    text = 'No user ['..memberid..'] in this SuperGroup.'
  end
if get_cmd == "channel_block" then
  for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
     local user_id = v.peer_id
     local channel_id = cb_extra.msg.to.id
     local sender = cb_extra.msg.from.id
      if user_id == sender then
        return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
      end
      if is_momod2(user_id, channel_id) and not is_admin2(sender) then
        return send_large_msg("channel#id"..channel_id, "⚠️You can't kick mods/owner/admins⚠️")
      end
      if is_admin2(user_id) then
        return send_large_msg("channel#id"..channel_id, "⚠️You can't kick other admins⚠️")
      end
      if v.username then
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..v.username.." ["..v.peer_id.."]")
      else
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..v.peer_id.."]")
      end
      kick_user(user_id, channel_id)
      return
    end
  end
elseif get_cmd == "تنظیم ادمین" then
   for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
      local user_id = "user#id"..v.peer_id
      local channel_id = "channel#id"..cb_extra.msg.to.id
      channel_set_admin(channel_id, user_id, ok_cb, false)
      if v.username then
        text = "@"..v.username.." ["..v.peer_id.."] 📍has been set as an admin"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..v.username.." ["..v.peer_id.."]")
      else
        text = "["..v.peer_id.."] 📍has been set as an admin"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin "..v.peer_id)
      end
	  if v.username then
		member_username = "@"..v.username
	  else
		member_username = string.gsub(v.print_name, '_', ' ')
	  end
		local receiver = channel_id
		local user_id = v.peer_id
		promote_admin(receiver, member_username, user_id)

    end
    send_large_msg(channel_id, text)
    return
 end
 elseif get_cmd == 'تنظیم صاحب' then
	for k,v in pairs(result) do
		vusername = v.username
		vpeer_id = tostring(v.peer_id)
		if vusername == member or vpeer_id == memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
					local user_id = "user#id"..v.peer_id
					channel_set_admin(receiver, user_id, ok_cb, false)
					data[tostring(channel)]['set_owner'] = tostring(v.peer_id)
					save_data(_config.moderation.data, data)
					savelog(channel, name_log.."["..from_id.."] set ["..v.peer_id.."] as owner by username")
				if result.username then
					text = member_username.." ["..v.peer_id.."] added as owner"
				else
					text = "["..v.peer_id.."] added as owner"
				end
			end
		elseif memberid and vusername ~= member and vpeer_id ~= memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
				data[tostring(channel)]['set_owner'] = tostring(memberid)
				save_data(_config.moderation.data, data)
				savelog(channel, name_log.."["..from_id.."] تنظیم ["..memberid.."] به عنوان صاحب با یوزرنیم")
				text = "["..memberid.."] صاحب شد"
			end
		end
	end
 end
send_large_msg(receiver, text)
end
--End non-channel_invite username actions

--'Set supergroup photo' function
local function set_supergroup_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
      return
  end
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/channel_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    channel_set_photo(receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'عکس ذخیره شد!!', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'ناموفق, لطفا مجددا امتحان کنید.', ok_cb, false)
  end
end

local function callback_clean_bots (extra, success, result)
  local msg = extra.msg
  local receiver = 'channel#id'..msg.to.id
  local channel_id = msg.to.id
  for k,v in pairs(result) do
  local users_id = v.peer_id
  kick_user(users_id,channel_id)
  end
end

--Run function
local function run(msg, matches)
	if msg.to.type == 'chat' then
		if matches[1] == 'تبدیل سوپرگروه' then
			if not is_admin1(msg) then
				return
			end
			local receiver = get_receiver(msg)
			chat_upgrade(receiver, ok_cb, false)
		end
	elseif msg.to.type == 'channel'then
		if matches[1] == 'تبدیل سوپرگروه' then
			if not is_admin1(msg) then
				return
			end
			return "درحال حاظر یک سوپرگروه است"
		end
	end
	if msg.to.type == 'channel' then
	local support_id = msg.from.id
	local receiver = get_receiver(msg)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	local data = load_data(_config.moderation.data)
		if matches[1] == 'add' and not matches[2] then
			if not is_admin1(msg) and not is_support(support_id) then
				return
			end
			if is_super_group(msg) then
				return reply_msg(msg.id, '✅سوپرگروه از قبل اضافه شده بود✅', ok_cb, false)
			end
			print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") added")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] added SuperGroup")
			superadd(msg)
			set_mutes(msg.to.id)
			channel_set_admin(receiver, 'user#id'..msg.from.id, ok_cb, false)
		end

		if matches[1] == 'حذف' and is_admin1(msg) and not matches[2] then
			if not is_super_group(msg) then
				return reply_msg(msg.id, '⚠️سوپرگروه اضافه نشده است⚠️', ok_cb, false)
			end
			print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") removed")
			superrem(msg)
			rem_mutes(msg.to.id)
		end

		if not data[tostring(msg.to.id)] then
			return
		end
		if matches[1] == "اطلاعات" then
			if not is_owner(msg) then
				return
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] اطلاعات سوپرگروه را درخواست کرد.")
			channel_info(receiver, callback_info, {receiver = receiver, msg = msg})
		end

		if matches[1] == "ادمین ها" then
			if not is_owner(msg) and not is_support(msg.from.id) then
				return
			end
			member_type = 'ادمین ها'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] لیست ادمین های سوپرگروه را درخواست کرد.")
			admins = channel_get_admins(receiver,callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "صاحب" then
			local group_owner = data[tostring(msg.to.id)]['set_owner']
			if not group_owner then
				return "مدیری وجود ندارد. از ادمین ها در ساپورت بپرسید."
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] used /owner")
			return "⭕️صاحب گروه ایشون هستند.⭕️ ["..group_owner..']'
		end

		if matches[1] == "لیست مدیران" then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] لیست مدیران را درخواست کرد.")
			return modlist(msg)
			-- channel_get_admins(receiver,callback, {receiver = receiver})
		end

		if matches[1] == "بات ها" and is_momod(msg) then
			member_type = 'بات ها'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] لیست بات های سوپرگروه را درخواست کرد.")
			channel_get_bots(receiver, callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "افراد" and not matches[2] and is_momod(msg) then
			local user_id = msg.from.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] لیست افراد سوپرگروه را درخواست کرد.")
			channel_get_users(receiver, callback_who, {receiver = receiver})
		end

		if matches[1] == "kicked" and is_momod(msg) then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested Kicked users list")
			channel_get_kicked(receiver, callback_kicked, {receiver = receiver})
		end

		if matches[1] == 'پاک' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'پاک',
					msg = msg
				}
				delete_msg(msg.id, ok_cb, false)
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			end
		end

		if matches[1] == 'بلاک' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'channel_block',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'block' and matches[2] and string.match(matches[2], '^%d+$') then
				--[[local user_id = matches[2]
				local channel_id = msg.to.id
				if is_momod2(user_id, channel_id) and not is_admin2(user_id) then
					return send_large_msg(receiver, "You can't kick mods/owner/admins")
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: [ user#id"..user_id.." ]")
				kick_user(user_id, channel_id)]]
				local get_cmd = 'channel_block'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == "block" and matches[2] and not string.match(matches[2], '^%d+$') then
			--[[local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'channel_block',
					sender = msg.from.id
				}
			    local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
			local get_cmd = 'channel_block'
			local msg = msg
			local username = matches[2]
			local username = string.gsub(matches[2], '@', '')
			channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'ایدی' then
			if type(msg.reply_id) ~= "nil" and is_momod(msg) and not matches[2] then
				local cbreply_extra = {
					get_cmd = 'ایدی',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif type(msg.reply_id) ~= "nil" and matches[2] == "from" and is_momod(msg) then
				local cbreply_extra = {
					get_cmd = 'idfrom',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif msg.text:match("@[%a%d]") then
				local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'id'
				}
				local username = matches[2]
				local username = username:gsub("@","")
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested ID for: @"..username)
				resolve_username(username,  callbackres, cbres_extra)
			else
				userrank = "کاربر"
				if is_sudo(msg) then
						userrank = "سودو و یا سازنده"
				elseif is_owner(msg) then
						userrank = "صاحب"
				elseif is_admin1(msg) then
						userrank = "ادمین"
				elseif is_momod(msg) then
						userrank = "مدیر"
				end
				number = "----"
				if msg.from.phone then
					number = "+98"..string.sub(msg.from.phone, 3)
					if string.sub(msg.from.phone, 0,4) == '9891' then
						number = number.."\n➖➖➖➖➖➖➖➖➖➖\n💢سیم کارت : ir-mci"
					elseif string.sub(msg.from.phone, 0,5) == '98932' then
						number = number.."\n➖➖➖➖➖➖➖➖➖➖\n💢سیم کارت : Taliya"
					elseif string.sub(msg.from.phone, 0,4) == '9893' then
						number = number.."\n➖➖➖➖➖➖➖➖➖➖\n💢سیم کارت : Irancell"
					elseif string.sub(msg.from.phone, 0,4) == '9890' then
						number = number.."\n➖➖➖➖➖➖➖➖➖➖\n💢سیم کارت : Irancell"
					elseif string.sub(msg.from.phone, 0,4) == '9892' then
						number = number.."\n➖➖➖➖➖➖➖➖➖➖\n💢سیم کارت : Rightel"
					else
						number = number.."\n➖➖➖➖➖➖➖➖➖➖\n💢سیم کارت : another"
					end
		        	end
				local user_info = {}
				local uhash = 'user:'..msg.from.id
				local user = redis:hgetall(uhash)
				local um_hash = 'msgs:'..msg.from.id..':'..msg.to.id
				user_info.msgs = tonumber(redis:get(um_hash) or 0)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup ID")
                                return "💢نام : "..(msg.from.first_name or "---").."\n💢نام خانوادگی : "..(msg.from.last_name or "---").."\n💢نام کاربری : @"..(msg.from.username or "---").."\n📡مقام : "..userrank.."\ایدی : "..msg.from.id.."\n🔢شماره تلفن : "..number.."\nℹ️تعداد پیام ها : "..user_info.msgs.."\n➖➖➖➖➖➖➖➖➖➖\n⭕️نام سوپرگروه : "..string.gsub(msg.to.print_name, "_", " ").."\n🆔ایدی سوپرگروه : "..msg.to.id                  
                        end
		end

		if matches[1] == 'خروج' then
			if msg.to.type == 'channel' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] left via kickme")
				channel_kick("channel#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
			end
		end

		if matches[1] == 'لینک جدید' and is_momod(msg)then
			local function callback_link (extra , success, result)
			local receiver = get_receiver(msg)
				if success == 0 then
					send_large_msg(receiver, '*ارور! ساخت لینک جدید ناموفق بود.* \nReason: سازنده نیستید..\n\nاگر لینک دارید آن را با دستور تنظیم لینک تنظیم نمایید.')
					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
				else
					send_large_msg(receiver, "لینک جدید ساخته شد.")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
					save_data(_config.moderation.data, data)
				end
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] تلاش برای ساخت لینک سوپرگروه")
			export_channel_link(receiver, callback_link, false)
		end

		if matches[1] == 'تنظیم لینک' and is_owner(msg) then
			data[tostring(msg.to.id)]['settings']['set_link'] = 'لطفا صبر کنید.'
			save_data(_config.moderation.data, data)
			return 'لطفا لینک جدید گروه را اکنون ارسال نمایید.'
		end

		if msg.text then
			if msg.text:match("^(https://telegram.me/joinchat/%S+)$") and data[tostring(msg.to.id)]['settings']['set_link'] == 'لطفا صبر کنید.' and is_owner(msg) then
				data[tostring(msg.to.id)]['settings']['set_link'] = msg.text
				save_data(_config.moderation.data, data)
				return "لینک جدید تنظیم شد."
			end
		end

		if matches[1] == 'لینک' then
			if not is_momod(msg) then
				return
			end
			local group_link = data[tostring(msg.to.id)]['settings']['set_link']
			if not group_link then
				return "اول با دستور لینک جدید لینک بسازید!\n\n اگر سازنده نیستم از دستور تنظیم لینک استفاده کنید."
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group link ["..group_link.."]")
			return '>⭕️نام سوپرگروه⭕️:\n["..msg.to.print_name.."]\n>🆔SuperGroup ID🆔:\n"..msg.to.id.."\n>✅More✅\n_______________________________\n🔷your link:Telegram.Me/"..msg.from.username.."\n>🔡GP link🔡:\n"..group_link'
		end

		if matches[1] == "دعوت" and is_sudo(msg) then
			local cbres_extra = {
				channel = get_receiver(msg),
				get_cmd = "دعوت"
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] invited @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		if matches[1] == 'res' and is_owner(msg) then
			local cbres_extra = {
				channelid = msg.to.id,
				get_cmd = 'res'
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] resolved username: @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		--[[if matches[1] == 'خروج' and is_momod(msg) then
			local receiver = channel..matches[3]
			local user = "user#id"..matches[2]
			chaannel_kick(receiver, user, ok_cb, false)
		end]]

			if matches[1] == 'تنظیم ادمین' then
				if not is_support(msg.from.id) and not is_owner(msg) then
					return
				end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'تنظیم ادمین',
					msg = msg
				}
				setadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'تنظیم ادمین' and matches[2] and string.match(matches[2], '^%d+$') then
			--[[]	local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'تنظیم ادمین'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})]]
				local get_cmd = 'تنظیم ادمین'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'تنظیم ادمین' and matches[2] and not string.match(matches[2], '^%d+$') then
				--[[local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'تنظیم ادمین'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
				local get_cmd = 'setadmin'
				local msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'demoteadmin' then
			if not is_support(msg.from.id) and not is_owner(msg) then
				return
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demoteadmin',
					msg = msg
				}
				demoteadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'demoteadmin' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demoteadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'demoteadmin' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demoteadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted admin @"..username)
				resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'setowner' and is_owner(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setowner',
					msg = msg
				}
				setowner = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'setowner' and matches[2] and string.match(matches[2], '^%d+$') then
		--[[	local group_owner = data[tostring(msg.to.id)]['set_owner']
				if group_owner then
					local receiver = get_receiver(msg)
					local user_id = "user#id"..group_owner
					if not is_admin2(group_owner) and not is_support(group_owner) then
						channel_demote(receiver, user_id, ok_cb, false)
					end
					local user = "user#id"..matches[2]
					channel_set_admin(receiver, user, ok_cb, false)
					data[tostring(msg.to.id)]['set_owner'] = tostring(matches[2])
					save_data(_config.moderation.data, data)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set ["..matches[2].."] as owner")
					local text = "[ "..matches[2].." ] added as owner"
					return text
				end]]
				local	get_cmd = 'setowner'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'setowner' and matches[2] and not string.match(matches[2], '^%d+$') then
				local	get_cmd = 'setowner'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'ترفیع' then
		  if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "Only owner/admin can promote"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'promote',
					msg = msg
				}
				promote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'promote' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'promote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'promote' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'promote',
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'mp' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_set_mod(channel, user_id, ok_cb, false)
			return "ok"
		end
		if matches[1] == 'md' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_demote(channel, user_id, ok_cb, false)
			return "ok"
		end

		if matches[1] == 'تنزل' then
			if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "Only owner/support/admin can promote"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'تنزل',
					msg = msg
				}
				demote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'تنزل' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'تنزل'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'تنزل' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'تنزل'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == "تنظیم نام" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local set_name = string.gsub(matches[2], '_', '')
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..matches[2])
			rename_channel(receiver, set_name, ok_cb, false)
		end

		if msg.service and msg.action.type == 'chat_rename' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..msg.to.title)
			data[tostring(msg.to.id)]['settings']['set_name'] = msg.to.title
			save_data(_config.moderation.data, data)
		end

		if matches[1] == "تنظیم اطلاعات" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local about_text = matches[2]
			local data_cat = 'description'
			local target = msg.to.id
			data[tostring(target)][data_cat] = about_text
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup description to: "..about_text)
			channel_set_about(receiver, about_text, ok_cb, false)
			return "Description has been set.\n\nSelect the chat again to see the changes."
		end

		if matches[1] == "تنظیم یوزرنیم" and is_admin1(msg) then
			local function ok_username_cb (extra, success, result)
				local receiver = extra.receiver
				if success == 1 then
					send_large_msg(receiver, "SuperGroup username Set.\n\nSelect the chat again to see the changes.")
				elseif success == 0 then
					send_large_msg(receiver, "Failed to set SuperGroup username.\nUsername may already be taken.\n\nNote: Username can use a-z, 0-9 and underscores.\nMinimum length is 5 characters.")
				end
			end
			local username = string.gsub(matches[2], '@', '')
			channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
		end

		if matches[1] == 'تنظیم قوانین' and is_momod(msg) then
			rules = matches[2]
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group rules to ["..matches[2].."]")
			return set_rulesmod(msg, data, target)
		end

		if msg.media then
			if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set new SuperGroup photo")
				load_photo(msg.id, set_supergroup_photo, msg)
				return
			end
		end
		if matches[1] == 'تنظیم عکس' and is_momod(msg) then
			data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] started setting new SuperGroup photo")
			return 'Please send the new group photo now'
		end

		if matches[1] == 'پاک کردن' then
			if not is_momod(msg) then
				return
			end
			if not is_momod(msg) then
				return "فقط صاحبان می توانند پاک کنند."
			end
			if matches[2] == 'modlist' then
				if next(data[tostring(msg.to.id)]['moderators']) == nil then
					return 'No moderator(s) in this SuperGroup.'
				end
				for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
					data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned modlist")
				return 'لیست مدیران پاک شد'
			end
			if matches[2] == 'قوانین' then
				local data_cat = 'rules'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return "قوانین تنظیم نشد"
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned rules")
				return 'قوانین پاک شد.'
			end
			if matches[2] == 'درباره' then
				local receiver = get_receiver(msg)
				local about_text = ' '
				local data_cat = 'description'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return 'اطلاعات تنظیم نشد'
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned about")
				channel_set_about(receiver, about_text, ok_cb, false)
				return "اطلاعات پاک شد"
			end
			if matches[2] == 'لیست افراد سایلنت' then
				chat_id = msg.to.id
				local hash =  'mute_user:'..chat_id
					redis:del(hash)
				return "لیست مات ها پاک شد"
			end
			if matches[2] == 'یوزرنیم' and is_admin1(msg) then
				local function ok_username_cb (extra, success, result)
					local receiver = extra.receiver
					if success == 1 then
						send_large_msg(receiver, "یوزرنیم سوپرگروه پاک شد.")
					elseif success == 0 then
						send_large_msg(receiver, "ناموفق برای پاک کردن یوزرنیم سوپرگروه.")
					end
				end
				local username = ""
				channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
			end
			if matches[2] == "بات ها" and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] تمامی بات های سوپرگروه اخراج شدند.")
				channel_get_bots(receiver, callback_clean_bots, {msg = msg})
			end
		end

		if matches[1] == 'قفل' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'links' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_links(msg, data, target)
			end
			if matches[2] == 'all' then
			local safemode ={
			 lock_group_links(msg, data, target),
	lock_group_tags(msg, data, target),
	lock_group_spam(msg, data, target),
	lock_group_flood(msg, data, target),
	lock_group_arabic(msg, data, target),
	lock_group_membermod(msg, data, target),
	lock_group_rtl(msg, data, target),
	lock_group_tgservice(msg, data, target),
	lock_group_sticker(msg, data, target),
	lock_group_contacts(msg, data, target),
	lock_group_english(msg, data, target),
	lock_group_fwd(msg, data, target),
	lock_group_reply(msg, data, target),
	lock_group_join(msg, data, target),
	lock_group_emoji(msg, data, target),
	lock_group_username(msg, data, target),
	lock_group_badword(msg, data, target),
	lock_group_media(msg, data, target),
	lock_group_leave(msg, data, target),
	lock_group_bots(msg, data, target),
	lock_group_operator(msg, data, target),
	lock_group_number(msg, data, target),
	  }
				return lock_group_all(msg, data, target), safemode
			end
			if matches[2] == 'tags' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked tags posting ")
				return lock_group_tags(msg, data, target)
			end
			if matches[2] == 'leave' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked leave ")
				return lock_group_leave(msg, data, target)
			end
			if matches[2] == 'operator' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked operator posting ")
				return lock_group_operator(msg, data, target)
			end
			if matches[2] == 'badword' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked badword posting ")
				return lock_group_badword(msg, data, target)
			end
			if matches[2] == 'number' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked number posting ")
				return lock_group_number(msg, data, target)
			end
			if matches[2] == 'reply' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked reply posting ")
				return lock_group_reply(msg, data, target)
			end
			if matches[2] == 'fwd' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked fwd posting ")
				return lock_group_fwd(msg, data, target)
			end
			if matches[2] == 'join' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked join ")
				return lock_group_join(msg, data, target)
			end
			if matches[2] == 'emoji' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked emoji posting ")
				return lock_group_emoji(msg, data, target)
			end
			if matches[2] == 'username' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked username posting ")
				return lock_group_username(msg, data, target)
			end
			if matches[2] == 'media' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked media posting ")
				return lock_group_media(msg, data, target)
			end
			if matches[2] == 'bots' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked adding bots  ")
				return lock_group_bots(msg, data, target)
			end
			if matches[2] == 'spam' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked spam ")
				return lock_group_spam(msg, data, target)
			end
			if matches[2] == 'flood' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood ")
				return lock_group_flood(msg, data, target)
			end
			if matches[2] == 'arabic' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked arabic ")
				return lock_group_arabic(msg, data, target)
			end
			if matches[2] == 'member' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked member ")
				return lock_group_membermod(msg, data, target)
			end
			if matches[2]:lower() == 'rtl' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked rtl chars. in names")
				return lock_group_rtl(msg, data, target)
			end
			if matches[2]:lower() == 'english' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked english chars. in names")
				return lock_group_english(msg, data, target)
			end
			if matches[2] == 'tgservice' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked Tgservice Actions")
				return lock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'sticker' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked sticker posting")
				return lock_group_sticker(msg, data, target)
			end
			if matches[2] == 'contacts' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_contacts(msg, data, target)
			end
			if matches[2] == 'strict' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked enabled strict settings")
				return enable_strict_rules(msg, data, target)
			end
		end

		if matches[1] == 'بازکردن' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'links' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_links(msg, data, target)
			end
			if matches[2] == 'all' then
			local dsafemode ={
			 unlock_group_links(msg, data, target),
	unlock_group_tags(msg, data, target),
	unlock_group_spam(msg, data, target),
	unlock_group_flood(msg, data, target),
	unlock_group_arabic(msg, data, target),
	unlock_group_membermod(msg, data, target),
	unlock_group_rtl(msg, data, target),
	unlock_group_tgservice(msg, data, target),
	unlock_group_sticker(msg, data, target),
	unlock_group_contacts(msg, data, target),
	unlock_group_english(msg, data, target),
	unlock_group_fwd(msg, data, target),
	unlock_group_reply(msg, data, target),
	unlock_group_join(msg, data, target),
	unlock_group_emoji(msg, data, target),
	unlock_group_username(msg, data, target),
	unlock_group_badword(msg, data, target),
	unlock_group_media(msg, data, target),
	unlock_group_leave(msg, data, target),
	unlock_group_bots(msg, data, target),
	unlock_group_operator(msg, data, target),
	unlock_group_number(msg, data, target),
	  }
				return unlock_group_all(msg, data, target), dsafemode
			end
			if matches[2] == 'tags' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tags posting ")
				return unlock_group_tags(msg, data, target)
			end
			if matches[2] == 'leave' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked leave ")
				return unlock_group_leave(msg, data, target)
			end
			if matches[2] == 'operator' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked operator posting")
				return unlock_group_operator(msg, data, target)
			end
			if matches[2] == 'badword' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked badword posting")
				return unlock_group_badword(msg, data, target)
			end
			if matches[2] == 'number' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked number posting")
				return unlock_group_number(msg, data, target)
			end
			if matches[2] == 'reply' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked reply posting ")
				return unlock_group_reply(msg, data, target)
			end
			if matches[2] == 'fwd' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked fwd posting ")
				return unlock_group_fwd(msg, data, target)
			end
			if matches[2] == 'join' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked join ")
				return unlock_group_join(msg, data, target)
			end
			if matches[2] == 'emoji' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked emoji posting ")
				return unlock_group_emoji(msg, data, target)
			end
			if matches[2] == 'username' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked username posting ")
				return unlock_group_username(msg, data, target)
			end
			if matches[2] == 'media' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked media posting ")
				return unlock_group_media(msg, data, target)
			end
			if matches[2] == 'bots' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked adding bots")
				return unlock_group_bots(msg, data, target)
			end
			if matches[2] == 'spam' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked spam")
				return unlock_group_spam(msg, data, target)
			end
			if matches[2] == 'flood' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == 'arabic' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked Arabic")
				return unlock_group_arabic(msg, data, target)
			end
			if matches[2] == 'member' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked member ")
				return unlock_group_membermod(msg, data, target)
			end
			if matches[2]:lower() == 'rtl' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked RTL chars. in names")
				return unlock_group_rtl(msg, data, target)
			end
			if matches[2]:lower() == 'english' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked english chars. in names")
				return unlock_group_english(msg, data, target)
			end
				if matches[2] == 'tgservice' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tgservice actions")
				return unlock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'sticker' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked sticker posting")
				return unlock_group_sticker(msg, data, target)
			end
			if matches[2] == 'contacts' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_contacts(msg, data, target)
			end
			if matches[2] == 'strict' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled strict settings")
				return disable_strict_rules(msg, data, target)
			end
		end

		if matches[1] == 'حساسیت' then
			if not is_momod(msg) then
				return
			end
			if tonumber(matches[2]) < 5 or tonumber(matches[2]) > 20 then
				return "Wrong number,range is [5-20]"
			end
			local flood_max = matches[2]
			data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set flood to ["..matches[2].."]")
			return 'Flood has been set to: '..matches[2]
		end
		if matches[1] == 'public' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == '✅' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: public")
				return set_public_membermod(msg, data, target)
			end
			if matches[2] == '❌' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: not public")
				return unset_public_membermod(msg, data, target)
			end
		end

		if matches[1] == 'سایلنت' and is_owner(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'صدا' then
			local msg_type = 'audio'
				if not is_muted(chat_id, msg_type..': فعال') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] سوپرگروه تنظیم شد به : mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." سایلنت شد"
				else
					return "مات سوپرگروه "..msg_type.." درحال حاضر فعال است"
				end
			end
			if matches[2] == 'تصویر' then
			local msg_type = 'photo'
				if not is_muted(chat_id, msg_type..': فعال') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." سایلنت شد"
				else
					return "SuperGroup mute "..msg_type.." درحال حاضر فعال است."
				end
			end
			if matches[2] == 'فیلم' then
			local msg_type = 'video'
				if not is_muted(chat_id, msg_type..': فعال') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." سایلنت شد"
				else
					return "SuperGroup mute "..msg_type.." درحال حاضر فعال است."
				end
			end
			if matches[2] == 'گیف' then
			local msg_type = 'gifs'
				if not is_muted(chat_id, msg_type..': فعال') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." سایلنت شد"
				else
					return "SuperGroup mute "..msg_type.." درحال حاضر فعال است."
				end
			end
			if matches[2] == 'اسناد' then
			local msg_type = 'documents'
				if not is_muted(chat_id, msg_type..': فعال') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." سایلنت شد"
				else
					return "SuperGroup mute "..msg_type.." درحال حاضر فعال است."
				end
			end
			if matches[2] == 'متن' then
			local msg_type = 'text'
				if not is_muted(chat_id, msg_type..': فعال') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." سایلنت شد"
				else
					return "Mute "..msg_type.." درحال حاضر فعال است."
				end
			end
			if matches[2] == 'همه' then
			local msg_type = 'all'
				if not is_muted(chat_id, msg_type..': فعال') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "Mute "..msg_type.."  فعال شد"
				else
					return "Mute "..msg_type.." درحال حاضر فعال است."
				end
			end
		end
		if matches[1] == 'رفع سایلنت' and is_momod(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'صدا' then
			local msg_type = 'audio'
				if is_muted(chat_id, msg_type..': فعال') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." رفع سایلنت شد"
				else
					return "Mute "..msg_type.." درحال حاضر غیرفعال است."
				end
			end
			if matches[2] == 'تصویر' then
			local msg_type = 'photo'
				if is_muted(chat_id, msg_type..': فعال') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." رفع سایلنت شد"
				else
					return "Mute "..msg_type.." درحال حاضر غیرفعال است."
				end
			end
			if matches[2] == 'فیلم' then
			local msg_type = 'video'
				if is_muted(chat_id, msg_type..': فعال') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." رفع سایلنت شد"
				else
					return "Mute "..msg_type.." درحال حاضر غیرفعال است."
				end
			end
			if matches[2] == 'گیف' then
			local msg_type = 'gifs'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." رفع سایلنت شد"
				else
					return "Mute "..msg_type.." درحال حاضر غیرفعال است."
				end
			end
			if matches[2] == 'اسناد' then
			local msg_type = 'documents'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." رفع سایلنت شد"
				else
					return "Mute "..msg_type.." درحال حاضر غیرفعال است."
				end
			end
			if matches[2] == 'متن' then
			local msg_type = 'text'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute message")
					unmute(chat_id, msg_type)
					return msg_type.." رفع سایلنت شد"
				else
					return "سایلنت متن درحال حاضر غیرفعال است."
				end
			end
			if matches[2] == 'همه' then
			local msg_type = 'all'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "Mute "..msg_type.." غیرفعال شد"
				else
					return "Mute "..msg_type.." درحال حاضر غیرفعال است."
				end
			end
		end


		if matches[1] == "muteuser" and is_momod(msg) then
			local chat_id = msg.to.id
			local hash = "mute_user"..chat_id
			local user_id = ""
			if type(msg.reply_id) ~= "nil" then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				muteuser = get_message(msg.reply_id, get_message_callback, {receiver = receiver, get_cmd = get_cmd, msg = msg})
			elseif matches[1] == "muteuser" and matches[2] and string.match(matches[2], '^%d+$') then
				local user_id = matches[2]
				if is_muted_user(chat_id, user_id) then
					unmute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed ["..user_id.."] from the muted users list")
					return "["..user_id.."] removed from the muted users list"
				elseif is_owner(msg) then
					mute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] added ["..user_id.."] to the muted users list")
					return "["..user_id.."] added to the muted user list"
				end
			elseif matches[1] == "muteuser" and matches[2] and not string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				resolve_username(username, callbackres, {receiver = receiver, get_cmd = get_cmd, msg=msg})
			end
		end

		if matches[1] == "لیست سایلنت" and is_momod(msg) then
			local chat_id = msg.to.id
			if not has_mutes(chat_id) then
				set_mutes(chat_id)
				return mutes_list(chat_id)
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup muteslist")
			return mutes_list(chat_id)
		end
		if matches[1] == "mutelist" and is_momod(msg) then
			local chat_id = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup mutelist")
			return muted_user_list(chat_id)
		end

		if matches[1] == 'تنظیمات' and is_momod(msg) then
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup settings ")
			return show_supergroup_settingsmod(msg, target)
		end

		if matches[1] == 'قوانین' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group rules")
			return get_rules(msg, data)
		end

		if matches[1] == 'راهنما' and not is_owner(msg) then
			local name_log = user_print_name(msg.from)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /superhelp")
			return super_help()
		elseif matches[1] == 'راهنما' and is_owner(msg) then
			local name_log = user_print_name(msg.from)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /superhelp")
			return super_help()
		end

		if matches[1] == 'peer_id' and is_admin1(msg)then
			text = msg.to.peer_id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		if matches[1] == 'msg.to.id' and is_admin1(msg) then
			text = msg.to.id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		--Admin Join Service Message
		if msg.service then
		local action = msg.action.type
			if action == 'chat_add_user_link' then
				if is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Admin ["..msg.from.id.."] joined the SuperGroup via link")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.from.id) and not is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Support member ["..msg.from.id.."] joined the SuperGroup")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
			if action == 'chat_add_user' then
				if is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Admin ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.action.user.id) and not is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Support member ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
		end
		if matches[1] == 'msg.to.peer_id' then
			post_large_msg(receiver, msg.to.peer_id)
		end
	end
end

local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end
  return msg
end

return {
  patterns = {
	"^افزودن$",
	"^حذف$",
	"^[#!/]([Mm]ove) (.*)$",
	"^اطلاعات$",
	"^ادمین ها$",
	"^صاحب$",
	"^لیست مدیران$",
	"^بات ها$",
	"^افراد$",
	"^کیک شده ها$",
    "^بلاک (.*)",
	"^بلاک",
	"^تبدیل سوپرگروه$",
	"^ایدی$",
	"^ایدی (.*)$",
	"^خروج$",
	"^اخراج (.*)$",
	"^لینک جدید$",
	"^تنظیم لینک$",
	"^لینک$",
	"^[#!/]([Rr]es) (.*)$",
	"^تنظیم ادمین (.*)$",
	"^تنظیم ادمین",
	"^تنزل ادمین (.*)$",
	"^تنزل ادمین",
	"^تنظیم صاحب (.*)$",
	"^تنظیم صاحب$",
	"^ترفیع (.*)$",
	"^ترفیع",
	"^تنزل (.*)$",
	"^تنزل",
	"^تنظیم نام (.*)$",
	"^تنظیم اطلاعات (.*)$",
	"^تنظیم قوانین (.*)$",
	"^تنظیم عکس$",
	"^تنظیم یوزرنیم (.*)$",
	"^پاک$",
	"^قفل (.*)$",
	"^بازکردن (.*)$",
	"^سایلنت ([^%s]+)$",
	"^رفع سایلنت ([^%s]+)$",
	"^[#!/]([Mm]uteuser)$",
	"^[#!/]([Mm]uteuser) (.*)$",
	"^قابل مشاهده بودن (.*)$",
	"^تنظیمات$",
	"^قوانین$",
	"^حساسیت (%d+)$",
	"^پاک کردن (.*)$",
	"^راهنما$",
	"^لیست سایلنت$",
	"^لیست افراد سایلنت$",
    "[#!/](mp) (.*)",
	"[#!/](md) (.*)",
    "^(https://telegram.me/joinchat/%S+)$",
	"msg.to.peer_id",
	"%[(document)%]",
	"%[(photo)%]",
	"%[(video)%]",
	"%[(audio)%]",
	"%[(contact)%]",
	"^!!tgservice (.+)$",
  },
  run = run,
  pre_process = pre_process
}
--End supergrpup.lua
--By @alireza_PT
--channel : @create_antispam_bot
--Edited by @Mr_AL_i
