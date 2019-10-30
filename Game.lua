require "Common/functions"
require "Logic/JsonFile"
require "Logic/SceneBattle"
require "Logic/GameData"
require "Logic/HttpRequest"
local json = require "cjson"
--管理器--
Game = {};
local this = Game;

local game; 
local transform;
local gameObject;

--初始化完成，发送链接服务器信息--
function Game.OnInitOK()
    GameManager:GetJsonWWW(AppConst.VersionUrl,this.CheckVersion);
end

function this.LoadingGame()
    JsonFile.OnLoad();
    Event.AddListener(Protocal.GCNoticeLayerChange,this.PlayerInfoCallback);
    Event.AddListener(Protocal.NC_NOTICEHOMECHANGE,this.NoticeHomeCallback);
    Event.AddListener(Protocal.GCMODIFYHOMEINFO,this.GCModifyHomeInfoCallback);
    Event.AddListener(Protocal.NC_DISCONNECT,this.NC_DISCONNECTCallback);
    UIManager:OpenPanel("Login","LoginPanel",HierarchyType.Middle);
end

function this.NC_DISCONNECTCallback(res)
    if res.msgno ~= 0 then
        WaitServerPanel.SetActive(false);
    end
end

function this.CheckVersion(text)
    if string.find(text,'ver') == nil then
        Game.ShowMsgBox(1,"请检测网络状况，退出后重试","退出",this.ApplicationQuit)
        return;
    end
    local infos = json.decode(text);
    for k,info in pairs(infos) do
        if string.find(AppConst.LoginServerIP, info.ip) ~= nil then
            if info.ver ~= UnityEngine.Application.version then
                Game.ShowMsgBox(1,"版本号不一致，更新客户端后重试","退出",this.ApplicationQuit)
                return false;
            end
        end
    end
    this.LoadingGame();
end

function this.StartClick()
    if GameData.BattleState == BattleState.Pause then
        this.ContineClick() 
    elseif GameData.BattleState == BattleState.End then
        Time.timeScale = 1;
        Event.Brocast(Events.BattleStart);
    end
end

function this.PauseClick()
    Time.timeScale = 1;
    SoundManager:PauseSoundMusic();
    GameData.BattleState = BattleState.Pause;
    Event.Brocast(Events.BattlePause);
end

function this.RestartClick()
    if GameData.BattleState == BattleState.Pause then
        Time.timeScale = 1;
    end
    GameData.BattleState = BattleState.Ing;
    Event.Brocast(Events.BattleRestart);
end

function this.ContineClick()    
    if GameData.BattleState == BattleState.Pause then
        Time.timeScale = 1;
        SoundManager:PlaySoundMusic();
        GameData.BattleState = BattleState.Ing
        Event.Brocast(Events.BattleContine);
    end
end

function this.StopClick()
    GameData.BattleState = BattleState.End
    SoundManager:StopAllMusic();
    StaffPanel.InitPanel()
    SceneBattle.InitPanel()
    for i =1,10 do
        LuaHelper.PrecisionAndSlider(i-1, 0);
    end
end

function Game.OpenPanel(assetName,name,hierarchyType)
	UIManager:OpenPanel(assetName,name,hierarchyType,nil) 
end

function Game.ClosePanel(name,closetype)
	UIManager:ClosePanel(name,closetype) 
end

function Game.TouchPG()
    if GameData.CurScene == Scene.Battle then
        BattleSkillPanel.TouchPGClick();
    end
end

function Game.TouchKeyIndex(keyId,playerId,deviceType,pad)
    if GameData.CurScene == Scene.Battle then
        Battle3DPanel.TouchKeyIndex(keyId,pad);
    end
end

function Game.GetDeviceInput(data)
    local jsonInfo = json.decode(data);
    if jsonInfo.type == "input" then
        if GameData.CurScene == Scene.Battle then
            local keyId,pad = JsonFile.GetKeyIDByDeviceCode(jsonInfo.note);
            if keyId ~= nil then
                Battle3DPanel.TouchKeyIndex(keyId,pad);
            end
        end
    end
end

function Game.GetKeyDown(keyId)
    if GameData.CurScene == Scene.Battle then
        SceneBattle.ExitScene();
    end
end

function Game.ChangeOffset(offset)
    GameData.NoteOffset = offset * 2;
end

function Game.ChangeSpeed(speed)
    GameData.BattleSpeed = (speed - 0.5) * 2;
end

function Game.GetSongName()
    return GameData.SongInfo.title;
end

function Game.ChangePlayer(playerId)
    StaffPanel.ChangePlayer(playerId)
end

function this.PlayerInfoData(res)
    if res.msgno == 0 and not GameData.IsMatching() then
        if res.type == 0 then
            local isexisit = false;
            for i = 1, #GameData.homeObj.playerArr do
                if GameData.homeObj.playerArr[i].uid == res.changeArr[1].uid then
                    isexisit = true;
                    GameData.homeObj.playerArr[i] = res.changeArr[1];
                end
            end
            if not isexisit then
                table.insert(GameData.homeObj.playerArr,res.changeArr[1]);
            end
        elseif res.type == 1 then
            for i = 1, #GameData.homeObj.playerArr do
                if res.changeArr[1].uid == GameData.homeObj.playerArr[i].uid then
                    table.remove(GameData.homeObj.playerArr,i);
                    break;
                end
            end
        else
            for i = 1, #GameData.homeObj.playerArr do
                if res.changeArr[1].uid == GameData.homeObj.playerArr[i].uid then
                    GameData.homeObj.playerArr[i] = res.changeArr[1];
                    GameData.homeObj.playerArr[i].startState = res.changeArr[1].startState;
                    GameData.homeObj.playerArr[i].gameState = res.changeArr[1].gameState;
                    break;
                end
            end
        end
    end
end

function this.NoticeHomeData(res)
    if res.msgno == 0 then
        if res.type == 1 then
            if res.homeId == GameData.homeObj.hid then
                GameData.homeObj.owner = res.nodifyId;
            end
        elseif res.type == 0 then
            GameData.SetSongSelectInfo(res.nodifyId);
        end
    end
end

function this.GCModifyHomeInfoData(res)
    if res.msgno == 0 then
        if res.type == 0 then
        GameData.SetSongSelectInfo(res.nodifyId);
        end
    end
end

function Game.PlayerInfoCallback(res)
    this.PlayerInfoData(res);
    Event.Brocast(Events.PlayerInfoWidget,res);
end

function Game.NoticeHomeCallback(res)
    this.NoticeHomeData(res);
    Event.Brocast(Events.NoticeHomeWidget,res);
end

function Game.GCModifyHomeInfoCallback(res)
    this.GCModifyHomeInfoData(res);
    Event.Brocast(Events.GCModifyHomeInfoWidget,res);
end

function Game.ShowMsgBox(Type,Des,ButtonText1,ButtonCallBack1,ButtonText2,ButtonCallBack2)
    for _,info in pairs(GameData.MsgInfos) do
        if info.Des == Des then
            return;
        end
    end
    MsgInfo = {
        Type = Type, --0确定 取消 1 确定
        Des = Des, --描述
        ButtonText1 = ButtonText1,
        ButtonText2 = ButtonText2,
        ButtonCallBack1 = ButtonCallBack1,
        ButtonCallBack2 = ButtonCallBack2,
    }
    table.insert(GameData.MsgInfos,MsgInfo)
    UIManager:OpenPanel("MsgBox","MsgBoxPanel",HierarchyType.Top);
end

function Game.Quit()
    if GameData.CurScene == Scene.Battle then
        Game.ShowMsgBox(0,"是否结束本场游戏","确定",this.ApplicationQuit,"取消",nil)
    else
        Game.ShowMsgBox(0,"是否退出游戏","退出",this.ApplicationQuit,"取消",nil)
    end
end

function Game.ChangeMusic(id)
    GameData.SongID = id;
end

function Game.ApplicationQuit()
    if GameData.CurScene == Scene.Battle then
        SceneBattle.ExitSceneCore(true,true)
    else
        UnityEngine.Application.Quit();
    end
end

function Game.OpenPanelRoomChosenPanel(type)
    if GameData.OpenRoomType ~= RoomType.Single and type == RoomType.Single then
        Game.InitMusic();
    end
    GameData.OpenRoomType = type == nil and RoomType.Room or type;
    UIManager:OpenPanel("RoomChosenUI","RoomChosenPanel",HierarchyType.Middle);
end

function Game.InitMusic()
    local info = JsonFile.GetJson("StaffDef")
    --测试用
    if #info == 2 then
        if GameData.Is5Key() then
            GameData.SongID = 1;
        else
            GameData.SongID = 2;
        end
        GameData.SongDif = 3;
    else
        for i, id in pairs(GameData.UserInfo.songInfoArr) do
            if info[id] ~= nil then
                local Musicid = GameData.GetMusicIDs(id,GameData.SongKeyMode);
                if #Musicid > 0 then
                    GameData.SongID = id;
                    break;
                elseif #Musicid > 0 then
                    GameData.SongID = id;
                    break;
                end
            end
        end
        GameData.SongID = info[GameData.SongID].id;
        if GameData.Is5Key() then
            for i = 1,#info[GameData.SongID].musicId5k  do
                if info[GameData.SongID].musicId5k[i] ~= 0 then
                    GameData.SongDif = i;
                    break;
                end
            end
        elseif GameData.Is8Key() then
            for i = 1,#info[GameData.SongID].musicId8k  do
                if info[GameData.SongID].musicId8k[i] ~= 0 then
                    GameData.SongDif = i;
                    break;
                end
            end
        end
    end
end

function Game.InitItemIcon(itemicon,id,count)
    
end

function Game.InitDuanInfo(DuanItem,score)
    local info = this.GetDuanID(score);
    DuanItem.Star = (info.id - 1) % 5;
    --ResManager:LoadImage("ImageDuan","IconDuan" .. math.floor(((info.id - 1) / 5 + 1)) ,DuanItem.ImageDuan)
    ResManager:LoadImage("ImageDuan","IconDuan1" ,DuanItem.ImageDuan)
end

function Game.GetDuanID(score)
    local rewards = JsonFile.GetJson("rank");
    for i = #rewards, 1, -1 do
        if score >= rewards[i].needPoint then
            return rewards[i];
        end
    end
end

function Game.GetNewDuanScore(score)
    local rewards = JsonFile.GetJson("rank");
    for i = #rewards, 1, -1 do
        if score >= rewards[i].needPoint then
            local info = JsonFile.GetRecordFromJson("rank",i+1)
            if info == nil then
                return "∞";
            else
                return info.needPoint;
            end
        end
    end
end

function Game.LoadModel(path,name,motion,parent,layer,callback,pos,rotate,scale,args)
    ResManager:LoadModel(path,name,motion,parent,layer,callback,pos,rotate,scale,args)
end

function Game.LoadModels(path,name,motion,parent,layer,callback,pos,rotate,scale)
    ResManager:LoadModels(path,name,motion,parent,layer,callback,pos,rotate,scale)
end

function Game.PlaySoundKey(name)
    SoundManager:EffectPlayWWW(name,true,GameData.keySound,false);
end

function Game.PlaySoundEffect(name)
    SoundManager:EffectPlayWWW(name,true,GameData.effectSound,false);
end

function Game.PlaySoundDuring(name)
    logError(name)
    SoundManager:EffectPlayWWW(name,false,GameData.effectSound,true);
end

function Game.StopSoundDuring()
    SoundManager:StopAudioEffect();
end

--销毁--
function Game.OnDestroy()
    Event.RemoveListener(Protocal.GCNoticeLayerChange);
    Event.RemoveListener(Protocal.NC_NOTICEHOMECHANGE);
    Event.RemoveListener(Protocal.GCMODIFYHOMEINFO);
    Event.RemoveListener(Protocal.NC_DISCONNECT);
end
