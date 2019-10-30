MsgBoxPanel = {};
local this = MsgBoxPanel;

local transform;
local gameObject;

local TextDes;
local ButtonOK;
local TextOK;
local ButtonCancel;
local TextCancel;
local ButtonClose;
local TextClose;

function this.Awake(obj)
	gameObject = obj;
    
	transform = obj.transform;
	luaBehaviour = gameObject:GetComponent('LuaBehaviour');
	local refObjs = {};
    local  objs = luaBehaviour.Objects;
    if objs.Count > 0 then
        for i=0,objs.Count - 1 do 
            local  go = objs[i];
            refObjs[go.name] = go;
        end
    end
    
    TextDes = refObjs['TextDes']:GetComponent("TextLangExtend");
    TextOK = refObjs['TextOK']:GetComponent("TextLangExtend");
    TextCancel = refObjs['TextCancel']:GetComponent("TextLangExtend");
    TextClose = refObjs['TextClose']:GetComponent("TextLangExtend");

    ButtonOK = refObjs['ButtonOK'];
    ButtonCancel = refObjs['ButtonCancel'];
    ButtonClose = refObjs['ButtonClose'];

    luaBehaviour:AddClick(ButtonOK,this.ButtonOKClick);
    luaBehaviour:AddClick(ButtonCancel,this.ButtonCancelClick);
    luaBehaviour:AddClick(ButtonClose,this.ButtonCloseClick);
    this.InitPanel()
end

function this.InitPanel()
    TextDes.text = GameData.MsgInfos[1].Des;
    if GameData.MsgInfos[1].Type == 0 then
        ButtonOK:SetActive(true)
        ButtonCancel:SetActive(true)
        ButtonClose:SetActive(false)
        TextOK.text = GameData.MsgInfos[1].ButtonText1;
        TextCancel.text = GameData.MsgInfos[1].ButtonText2;
    else
        ButtonClose:SetActive(true)
        ButtonOK:SetActive(false)
        ButtonCancel:SetActive(false)
        TextClose.text = GameData.MsgInfos[1].ButtonText1;
    end
end

function this.ButtonOKClick()
    if GameData.MsgInfos[1].ButtonCallBack1 ~= nil then
        GameData.MsgInfos[1].ButtonCallBack1();
    end
    this.Close();
end

function this.ButtonCancelClick()
    if GameData.MsgInfos[1].ButtonCallBack2 ~= nil then
        GameData.MsgInfos[1].ButtonCallBack2();
    end
    this.Close();
end

function this.ButtonCloseClick()
    if GameData.MsgInfos[1] ~= nil and GameData.MsgInfos[1].ButtonCallBack1 ~= nil then
        GameData.MsgInfos[1].ButtonCallBack1();
        table.remove(GameData.MsgInfos,1)
    end
    this.Close();
end

function this.ChangeScene()
    if GameData.MsgInfos ~= nil and #GameData.MsgInfos > 0 and GameData.MsgInfos[1].Type == 0 then
        this.Close();
    end
end

function this.Close()
    table.remove(GameData.MsgInfos,1)
    if #GameData.MsgInfos == 0 then
        UIManager:ClosePanel("MsgBoxPanel",UIPanelCloseType.Destroy);
    else
        this.InitPanel()
    end
end

function this.OnDestroy()
	gameObject = nil;
	transform = nil;
    luaBehaviour = nil;
    TextDes = nil;
    ButtonOK = nil;
    TextOK = nil;
    ButtonCancel = nil;
    TextCancel = nil;
    ButtonClose = nil;
    TextClose = nil;
end
