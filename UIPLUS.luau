--!strict

-- UIPlus: A Comprehensive UI Library Based on TopbarPlus Architecture
-- Capable of creating complex interfaces like Rayfield hubs

-- SERVICES
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local GamepadService = game:GetService("GamepadService")

-- TYPES
export type Connection = {
	Disconnect: (self: Connection) -> (),
}

export type Signal<T... = ...any> = {
	Connect: (self: Signal<T...>, func: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, func: (T...) -> ()) -> Connection,
	Wait: (self: Signal<T...>) -> T...,
	Fire: (self: Signal<T...>, ...T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
}

export type UIState = "Default" | "Selected" | "Hovered" | "Disabled"
export type Alignment = "Left" | "Center" | "Right"
export type EventSource = "User" | "Programmatic"

export type UIElement = {
	-- Core Properties
	UID: string,
	name: string,
	isEnabled: boolean,
	isVisible: boolean,
	isSelected: boolean,
	locked: boolean,
	parent: UIElement?,
	children: {UIElement},
	position: UDim2,
	size: UDim2,
	anchorPoint: Vector2,
	zIndex: number,
	layoutOrder: number,
	
	-- Visual Properties
	backgroundColor: Color3,
	backgroundTransparency: number,
	borderColor: Color3,
	borderSize: number,
	cornerRadius: UDim,
	text: string,
	textColor: Color3,
	textSize: number,
	textFont: Font,
	image: string,
	imageColor: Color3,
	imageTransparency: number,
	
	-- Events
	selected: Signal<EventSource>,
	deselected: Signal<EventSource>,
	clicked: Signal<Vector2, EventSource>,
	hovered: Signal<EventSource>,
	unhovered: Signal<EventSource>,
	rightClicked: Signal<Vector2, EventSource>,
	valueChanged: Signal<any>,
	childAdded: Signal<UIElement>,
	childRemoved: Signal<UIElement>,
	
	-- Methods
	Destroy: (self: UIElement) -> (),
	SetParent: (self: UIElement, parent: UIElement) -> UIElement,
	AddChild: (self: UIElement, child: UIElement) -> UIElement,
	RemoveChild: (self: UIElement, child: UIElement) -> boolean,
	SetVisible: (self: UIElement, visible: boolean) -> UIElement,
	SetEnabled: (self: UIElement, enabled: boolean) -> UIElement,
	SetPosition: (self: UIElement, position: UDim2) -> UIElement,
	SetSize: (self: UIElement, size: UDim2) -> UIElement,
	SetText: (self: UIElement, text: string) -> UIElement,
	SetImage: (self: UIElement, image: string | number) -> UIElement,
	SetColor: (self: UIElement, color: Color3) -> UIElement,
	SetTransparency: (self: UIElement, transparency: number) -> UIElement,
	SetCornerRadius: (self: UIElement, radius: UDim) -> UIElement,
	TweenPosition: (self: UIElement, position: UDim2, duration: number?, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?) -> UIElement,
	TweenSize: (self: UIElement, size: UDim2, duration: number?, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?) -> UIElement,
	TweenColor: (self: UIElement, color: Color3, duration: number?, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?) -> UIElement,
	BindEvent: (self: UIElement, event: string, callback: (...any) -> ()) -> Connection,
	BindKey: (self: UIElement, keyCode: Enum.KeyCode, callback: () -> ()) -> Connection,
	SetTooltip: (self: UIElement, text: string) -> UIElement,
	SetOrder: (self: UIElement, order: number) -> UIElement,
	SetPadding: (self: UIElement, padding: UDim) -> UIElement,
	SetMargin: (self: UIElement, margin: UDim) -> UIElement,
	SetFlexDirection: (self: UIElement, direction: Enum.FillDirection) -> UIElement,
	SetAlignment: (self: UIElement, horizontal: Enum.HorizontalAlignment?, vertical: Enum.VerticalAlignment?) -> UIElement,
	SetOverflow: (self: UIElement, overflow: Enum.OverflowMode) -> UIElement,
	SetScrollable: (self: UIElement, scrollable: boolean) -> UIElement,
	SetDraggable: (self: UIElement, draggable: boolean) -> UIElement,
	SetSelectable: (self: UIElement, selectable: boolean) -> UIElement,
	SetResizable: (self: UIElement, resizable: boolean) -> UIElement,
	SetClipsDescendants: (self: UIElement, clips: boolean) -> UIElement,
	SetAutoSize: (self: UIElement, autoSize: Enum.AutomaticSize) -> UIElement,
	SetTheme: (self: UIElement, theme: any) -> UIElement,
	Refresh: (self: UIElement) -> UIElement,
	BringToFront: (self: UIElement) -> UIElement,
	SendToBack: (self: UIElement) -> UIElement,
	FindFirstChild: (self: UIElement, name: string) -> UIElement?,
	FindFirstChildOfClass: (self: UIElement, className: string) -> UIElement?,
	GetChildren: (self: UIElement) -> {UIElement},
	GetDescendants: (self: UIElement) -> {UIElement},
	GetAbsolutePosition: (self: UIElement) -> Vector2,
	GetAbsoluteSize: (self: UIElement) -> Vector2,
	IsDescendantOf: (self: UIElement, ancestor: UIElement) -> boolean,
	IsAncestorOf: (self: UIElement, descendant: UIElement) -> boolean,
	
	-- Internal
	_instance: GuiBase2d?,
	_janitor: any,
	_connections: {Connection},
	_theme: any,
}

export type Window = UIElement & {
	title: string,
	minimized: boolean,
	maximized: boolean,
	draggable: boolean,
	resizable: boolean,
	closeable: boolean,
	minimizable: boolean,
	maximizable: boolean,
	
	-- Window Methods
	Minimize: (self: Window) -> Window,
	Maximize: (self: Window) -> Window,
	Restore: (self: Window) -> Window,
	Close: (self: Window) -> Window,
	SetTitle: (self: Window, title: string) -> Window,
	SetTitleBar: (self: Window, visible: boolean) -> Window,
	SetCloseButton: (self: Window, visible: boolean) -> Window,
	SetMinimizeButton: (self: Window, visible: boolean) -> Window,
	SetMaximizeButton: (self: Window, visible: boolean) -> Window,
	SetIcon: (self: Window, icon: string | number) -> Window,
	SetAccentColor: (self: Window, color: Color3) -> Window,
}

export type Button = UIElement & {
	buttonType: "Default" | "Primary" | "Secondary" | "Danger" | "Success" | "Warning",
	rounded: boolean,
	icon: string?,
	iconPosition: "Left" | "Right",
	loading: boolean,
	
	-- Button Methods
	SetButtonType: (self: Button, buttonType: string) -> Button,
	SetRounded: (self: Button, rounded: boolean) -> Button,
	SetIcon: (self: Button, icon: string | number, position: "Left" | "Right"?) -> Button,
	SetLoading: (self: Button, loading: boolean) -> Button,
	Click: (self: Button) -> Button,
}

export type TextBox = UIElement & {
	placeholder: string,
	text: string,
	clearTextOnFocus: boolean,
	multiLine: boolean,
	textEditable: boolean,
	characterLimit: number,
	textType: "Default" | "Password" | "Number" | "Email" | "Phone",
	
	-- TextBox Methods
	SetPlaceholder: (self: TextBox, text: string) -> TextBox,
	SetClearTextOnFocus: (self: TextBox, clear: boolean) -> TextBox,
	SetMultiLine: (self: TextBox, multiLine: boolean) -> TextBox,
	SetTextEditable: (self: TextBox, editable: boolean) -> TextBox,
	SetCharacterLimit: (self: TextBox, limit: number) -> TextBox,
	SetTextType: (self: TextBox, textType: string) -> TextBox,
	Focus: (self: TextBox) -> TextBox,
	Clear: (self: TextBox) -> TextBox,
	SelectAll: (self: TextBox) -> TextBox,
}

export type Label = UIElement & {
	text: string,
	textWrapped: boolean,
	textScaled: boolean,
	textXAlignment: Enum.TextXAlignment,
	textYAlignment: Enum.TextYAlignment,
	textTruncate: Enum.TextTruncate,
	richText: boolean,
	
	-- Label Methods
	SetTextWrapped: (self: Label, wrapped: boolean) -> Label,
	SetTextScaled: (self: Label, scaled: boolean) -> Label,
	SetTextAlignment: (self: Label, xAlignment: Enum.TextXAlignment?, yAlignment: Enum.TextYAlignment?) -> Label,
	SetTextTruncate: (self: Label, truncate: Enum.TextTruncate) -> Label,
	SetRichText: (self: Label, rich: boolean) -> Label,
}

export type Toggle = UIElement & {
	value: boolean,
	toggled: Signal<boolean, EventSource>,
	
	-- Toggle Methods
	SetValue: (self: Toggle, value: boolean) -> Toggle,
	Toggle: (self: Toggle) -> Toggle,
}

export type Slider = UIElement & {
	value: number,
	min: number,
	max: number,
	step: number,
	valueChanged: Signal<number, EventSource>,
	
	-- Slider Methods
	SetValue: (self: Slider, value: number) -> Slider,
	SetRange: (self: Slider, min: number, max: number) -> Slider,
	SetStep: (self: Slider, step: number) -> Slider,
	Increment: (self: Slider, amount: number) -> Slider,
	Decrement: (self: Slider, amount: number) -> Slider,
}

export type Dropdown = UIElement & {
	options: {string},
	selected: string?,
	multiSelect: boolean,
	selectedChanged: Signal<string | {string}, EventSource>,
	
	-- Dropdown Methods
	SetOptions: (self: Dropdown, options: {string}) -> Dropdown,
	SetSelected: (self: Dropdown, selected: string | {string}) -> Dropdown,
	SetMultiSelect: (self: Dropdown, multiSelect: boolean) -> Dropdown,
	AddOption: (self: Dropdown, option: string) -> Dropdown,
	RemoveOption: (self: Dropdown, option: string) -> Dropdown,
	ClearOptions: (self: Dropdown) -> Dropdown,
	Open: (self: Dropdown) -> Dropdown,
	Close: (self: Dropdown) -> Dropdown,
}

export type ColorPicker = UIElement & {
	color: Color3,
	colorChanged: Signal<Color3, EventSource>,
	
	-- ColorPicker Methods
	SetColor: (self: ColorPicker, color: Color3) -> ColorPicker,
	SetHexColor: (self: ColorPicker, hex: string) -> ColorPicker,
	SetRGB: (self: ColorPicker, r: number, g: number, b: number) -> ColorPicker,
	SetHSV: (self: ColorPicker, h: number, s: number, v: number) -> ColorPicker,
}

export type Keybind = UIElement & {
	key: Enum.KeyCode?,
	keyChanged: Signal<Enum.KeyCode, EventSource>,
	listening: boolean,
	
	-- Keybind Methods
	SetKey: (self: Keybind, key: Enum.KeyCode) -> Keybind,
	StartListening: (self: Keybind) -> Keybind,
	StopListening: (self: Keybind) -> Keybind,
}

export type Tab = UIElement & {
	title: string,
	icon: string?,
	selected: boolean,
	
	-- Tab Methods
	SetTitle: (self: Tab, title: string) -> Tab,
	SetIcon: (self: Tab, icon: string | number) -> Tab,
	Select: (self: Tab) -> Tab,
}

export type TabContainer = UIElement & {
	tabs: {Tab},
	selectedTab: Tab?,
	tabChanged: Signal<Tab, EventSource>,
	
	-- TabContainer Methods
	AddTab: (self: TabContainer, tab: Tab) -> TabContainer,
	RemoveTab: (self: TabContainer, tab: Tab) -> TabContainer,
	SelectTab: (self: TabContainer, tab: Tab | number | string) -> TabContainer,
	GetTab: (self: TabContainer, indexOrTitle: number | string) -> Tab?,
}

export type Notification = UIElement & {
	title: string,
	message: string,
	duration: number,
	type: "Info" | "Success" | "Warning" | "Error",
	
	-- Notification Methods
	SetTitle: (self: Notification, title: string) -> Notification,
	SetMessage: (self: Notification, message: string) -> Notification,
	SetDuration: (self: Notification, duration: number) -> Notification,
	SetType: (self: Notification, notificationType: string) -> Notification,
	Show: (self: Notification) -> Notification,
	Hide: (self: Notification) -> Notification,
	Dismiss: (self: Notification) -> Notification,
}

export type UIPlus = {
	-- Core Methods
	new: () -> UIPlus,
	Destroy: (self: UIPlus) -> (),
	
	-- UI Creation Methods
	CreateWindow: (self: UIPlus, title: string, size: UDim2?, position: UDim2?) -> Window,
	CreateButton: (self: UIPlus, text: string, parent: UIElement?) -> Button,
	CreateTextBox: (self: UIPlus, placeholder: string, parent: UIElement?) -> TextBox,
	CreateLabel: (self: UIPlus, text: string, parent: UIElement?) -> Label,
	CreateToggle: (self: UIPlus, text: string, defaultValue: boolean?, parent: UIElement?) -> Toggle,
	CreateSlider: (self: UIPlus, text: string, min: number, max: number, defaultValue: number?, parent: UIElement?) -> Slider,
	CreateDropdown: (self: UIPlus, text: string, options: {string}, parent: UIElement?) -> Dropdown,
	CreateColorPicker: (self: UIPlus, text: string, defaultValue: Color3?, parent: UIElement?) -> ColorPicker,
	CreateKeybind: (self: UIPlus, text: string, defaultKey: Enum.KeyCode?, parent: UIElement?) -> Keybind,
	CreateTab: (self: UIPlus, title: string, icon: string | number?, parent: UIElement?) -> Tab,
	CreateTabContainer: (self: UIPlus, parent: UIElement?) -> TabContainer,
	CreateNotification: (self: UIPlus, title: string, message: string, duration: number?, parent: UIElement?) -> Notification,
	CreateFrame: (self: UIPlus, parent: UIElement?) -> UIElement,
	CreateScrollingFrame: (self: UIPlus, parent: UIElement?) -> UIElement,
	CreateListLayout: (self: UIPlus, direction: Enum.FillDirection, parent: UIElement?) -> UIElement,
	CreateGridLayout: (self: UIPlus, cellSize: UDim2, parent: UIElement?) -> UIElement,
	CreatePadding: (self: UIPlus, padding: UDim, parent: UIElement?) -> UIElement,
	
	-- Utility Methods
	GetMousePosition: (self: UIPlus) -> Vector2,
	GetScreenSize: (self: UIPlus) -> Vector2,
	CreateSignal: () -> Signal<any>,
	CreateJanitor: () -> any,
	CreateTween: (instance: Instance, tweenInfo: TweenInfo, properties: any) -> Tween,
	Wait: (seconds: number) -> (),
	Debounce: (name: string, callback: () -> (), waitTime: number) -> (),
	Round: (number: number) -> number,
	GenerateUID: (length: number?) -> string,
	CopyTable: (table: any) -> any,
	
	-- Theme Methods
	SetTheme: (self: UIPlus, theme: any) -> (),
	GetTheme: (self: UIPlus) -> any,
	SetAccentColor: (self: UIPlus, color: Color3) -> (),
	GetAccentColor: (self: UIPlus) -> Color3,
	SetFont: (self: UIPlus, font: Font) -> (),
	GetFont: (self: UIPlus) -> Font,
	SetTransparency: (self: UIPlus, transparency: number) -> (),
	GetTransparency: (self: UIPlus) -> number,
	
	-- Notification Methods
	ShowNotification: (self: UIPlus, title: string, message: string, duration: number?, type: string?) -> Notification,
	ShowInfo: (self: UIPlus, title: string, message: string, duration: number?) -> Notification,
	ShowSuccess: (self: UIPlus, title: string, message: string, duration: number?) -> Notification,
	ShowWarning: (self: UIPlus, title: string, message: string, duration: number?) -> Notification,
	ShowError: (self: UIPlus, title: string, message: string, duration: number?) -> Notification,
	
	-- Rayfield-Style Hub Methods
	CreateHub: (self: UIPlus, title: string, size: UDim2?) -> Window,
	CreateTabbedHub: (self: UIPlus, title: string, size: UDim2?) -> (Window, TabContainer),
	CreateSection: (self: UIPlus, title: string, parent: UIElement?) -> UIElement,
	CreateDivider: (self: UIPlus, parent: UIElement?) -> UIElement,
	CreateParagraph: (self: UIPlus, text: string, parent: UIElement?) -> UIElement,
	CreateTitle: (self: UIPlus, text: string, parent: UIElement?) -> UIElement,
	CreateSubtitle: (self: UIPlus, text: string, parent: UIElement?) -> UIElement,
	
	-- Configuration
	SetDisplayOrder: (self: UIPlus, order: number) -> (),
	SetTopbarEnabled: (self: UIPlus, enabled: boolean) -> (),
	SetWatermark: (self: UIPlus, text: string, enabled: boolean) -> (),
	SetKeybind: (self: UIPlus, key: Enum.KeyCode, callback: () -> ()) -> Connection,
	SetToggleKey: (self: UIPlus, key: Enum.KeyCode) -> (),
	
	-- Events
	ElementCreated: Signal<UIElement>,
	ElementDestroyed: Signal<UIElement>,
	ThemeChanged: Signal<any>,
	NotificationCreated: Signal<Notification>,
	HubCreated: Signal<Window>,
	
	-- Internal
	_elements: {[string]: UIElement},
	_windows: {Window},
	_notifications: {Notification},
	_theme: any,
	_accentColor: Color3,
	_font: Font,
	_transparency: number,
	_janitor: any,
}

-- MODULES
local Signal = {} do
	-- Batched Yield-Safe Signal Implementation
	local freeRunnerThread = nil
	
	local function acquireRunnerThreadAndCallEventHandler(fn, ...)
		local acquiredRunnerThread = freeRunnerThread
		freeRunnerThread = nil
		fn(...)
		freeRunnerThread = acquiredRunnerThread
	end
	
	local function runEventHandlerInFreeThread()
		while true do
			acquireRunnerThreadAndCallEventHandler(coroutine.yield())
		end
	end
	
	local Connection = {}
	Connection.__index = Connection
	
	function Connection.new(signal, fn)
		return setmetatable({
			_connected = true,
			_signal = signal,
			_fn = fn,
			_next = false,
		}, Connection)
	end
	
	function Connection:Disconnect()
		self._connected = false
		if self._signal._handlerListHead == self then
			self._signal._handlerListHead = self._next
		else
			local prev = self._signal._handlerListHead
			while prev and prev._next ~= self do
				prev = prev._next
			end
			if prev then
				prev._next = self._next
			end
		end
	end
	Connection.Destroy = Connection.Disconnect
	
	local Signal = {}
	Signal.__index = Signal
	
	function Signal.new()
		return setmetatable({
			_handlerListHead = false,
		}, Signal)
	end
	
	function Signal:Connect(fn)
		local connection = Connection.new(self, fn)
		if self._handlerListHead then
			connection._next = self._handlerListHead
			self._handlerListHead = connection
		else
			self._handlerListHead = connection
		end
		return connection
	end
	
	function Signal:DisconnectAll()
		self._handlerListHead = false
	end
	Signal.Destroy = Signal.DisconnectAll
	
	function Signal:Fire(...)
		local item = self._handlerListHead
		while item do
			if item._connected then
				if not freeRunnerThread then
					freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
					coroutine.resume(freeRunnerThread)
				end
				task.spawn(freeRunnerThread, item._fn, ...)
			end
			item = item._next
		end
	end
	
	function Signal:Wait()
		local waitingCoroutine = coroutine.running()
		local cn;
		cn = self:Connect(function(...)
			cn:Disconnect()
			task.spawn(waitingCoroutine, ...)
		end)
		return coroutine.yield()
	end
	
	function Signal:Once(fn)
		local cn;
		cn = self:Connect(function(...)
			if cn._connected then
				cn:Disconnect()
			end
			fn(...)
		end)
		return cn
	end
	
	return Signal
end

local Janitor = {} do
	-- Janitor implementation for cleanup
	local Janitor = {
		ClassName = "Janitor";
	}
	
	function Janitor.new()
		return setmetatable({
			_objects = {};
		}, Janitor)
	end
	
	function Janitor:Add(object, methodName, index)
		if index then
			self:Remove(index)
			self._objects[index] = object
		end
		
		local objectType = typeof(object)
		methodName = methodName or (objectType == "function" and true) or "Destroy"
		
		if objectType ~= "function" and not object[methodName] then
			warn(string.format("Object %s doesn't have method %s", tostring(object), tostring(methodName)))
		end
		
		self[object] = methodName
		return object
	end
	
	function Janitor:Remove(index)
		local object = self._objects[index]
		if object then
			local methodName = self[object]
			if methodName then
				if methodName == true then
					object()
				else
					local objectMethod = object[methodName]
					if objectMethod then
						objectMethod(object)
					end
				end
				self[object] = nil
			end
			self._objects[index] = nil
		end
		return self
	end
	
	function Janitor:Cleanup()
		for object, methodName in pairs(self) do
			if object == "_objects" then continue end
			if methodName == true then
				object()
			else
				local objectMethod = object[methodName]
				if objectMethod then
					objectMethod(object)
				end
			end
			self[object] = nil
		end
		for index in pairs(self._objects) do
			self._objects[index] = nil
		end
	end
	
	function Janitor:Destroy()
		self:Cleanup()
	end
	
	Janitor.__call = Janitor.Cleanup
	
	return Janitor
end

local Utility = {} do
	function Utility.CreateStagger(delayTime, callback, delayInitially)
		local staggerActive = false
		local multipleCalls = false
		if not delayTime or delayTime == 0 then
			delayTime = 0.01
		end
		
		local function staggeredCallback(...)
			if staggerActive then
				multipleCalls = true
				return
			end
			local packedArgs = table.pack(...)
			staggerActive = true
			multipleCalls = false
			task.spawn(function()
				if delayInitially then
					task.wait(delayTime)
				end
				callback(table.unpack(packedArgs))
			end)
			task.delay(delayTime, function()
				staggerActive = false
				if multipleCalls then
					staggeredCallback(table.unpack(packedArgs))
				end
			end)
		end
		
		return staggeredCallback
	end
	
	function Utility.Round(n)
		return math.floor(n + 0.5)
	end
	
	function Utility.GenerateUID(length)
		length = length or 8
		local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		local uid = ""
		for i = 1, length do
			local rand = math.random(1, #chars)
			uid = uid .. string.sub(chars, rand, rand)
		end
		return uid
	end
	
	function Utility.CopyTable(t)
		local copy = {}
		for k, v in pairs(t) do
			if type(v) == "table" then
				copy[k] = Utility.CopyTable(v)
			else
				copy[k] = v
			end
		end
		return copy
	end
	
	function Utility.FormatStateName(name)
		return string.upper(string.sub(name, 1, 1)) .. string.lower(string.sub(name, 2))
	end
end

-- UIPlus IMPLEMENTATION
local UIPlus = {}
UIPlus.__index = UIPlus

-- Default Theme
local DEFAULT_THEME = {
	AccentColor = Color3.fromRGB(0, 170, 255),
	BackgroundColor = Color3.fromRGB(30, 30, 30),
	BackgroundTransparency = 0.1,
	ForegroundColor = Color3.fromRGB(255, 255, 255),
	SecondaryColor = Color3.fromRGB(50, 50, 50),
	BorderColor = Color3.fromRGB(60, 60, 60),
	TextColor = Color3.fromRGB(255, 255, 255),
	DisabledColor = Color3.fromRGB(100, 100, 100),
	ErrorColor = Color3.fromRGB(255, 85, 85),
	SuccessColor = Color3.fromRGB(85, 255, 85),
	WarningColor = Color3.fromRGB(255, 255, 85),
	InfoColor = Color3.fromRGB(85, 170, 255),
	
	Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
	TextSize = 14,
	CornerRadius = UDim.new(0, 6),
	Padding = 8,
	Margin = 4,
	
	Window = {
		TitleBarHeight = 32,
		TitleBarColor = Color3.fromRGB(40, 40, 40),
		TitleTextColor = Color3.fromRGB(255, 255, 255),
		TitleTextSize = 18,
	},
	
	Button = {
		Default = {
			BackgroundColor = Color3.fromRGB(50, 50, 50),
			TextColor = Color3.fromRGB(255, 255, 255),
		},
		Primary = {
			BackgroundColor = Color3.fromRGB(0, 170, 255),
			TextColor = Color3.fromRGB(255, 255, 255),
		},
		Secondary = {
			BackgroundColor = Color3.fromRGB(70, 70, 70),
			TextColor = Color3.fromRGB(255, 255, 255),
		},
		Danger = {
			BackgroundColor = Color3.fromRGB(220, 60, 60),
			TextColor = Color3.fromRGB(255, 255, 255),
		},
		Success = {
			BackgroundColor = Color3.fromRGB(60, 220, 60),
			TextColor = Color3.fromRGB(255, 255, 255),
		},
		Warning = {
			BackgroundColor = Color3.fromRGB(220, 220, 60),
			TextColor = Color3.fromRGB(30, 30, 30),
		},
	},
	
	TextBox = {
		BackgroundColor = Color3.fromRGB(40, 40, 40),
		TextColor = Color3.fromRGB(255, 255, 255),
		PlaceholderColor = Color3.fromRGB(150, 150, 150),
		BorderColor = Color3.fromRGB(60, 60, 60),
	},
	
	Toggle = {
		OnColor = Color3.fromRGB(0, 170, 255),
		OffColor = Color3.fromRGB(70, 70, 70),
		KnobColor = Color3.fromRGB(255, 255, 255),
	},
	
	Slider = {
		TrackColor = Color3.fromRGB(70, 70, 70),
		FillColor = Color3.fromRGB(0, 170, 255),
		KnobColor = Color3.fromRGB(255, 255, 255),
	},
	
	Dropdown = {
		BackgroundColor = Color3.fromRGB(40, 40, 40),
		HoverColor = Color3.fromRGB(50, 50, 50),
		SelectedColor = Color3.fromRGB(0, 170, 255),
	},
	
	Tab = {
		BackgroundColor = Color3.fromRGB(40, 40, 40),
		SelectedColor = Color3.fromRGB(0, 170, 255),
		TextColor = Color3.fromRGB(200, 200, 200),
		SelectedTextColor = Color3.fromRGB(255, 255, 255),
	},
	
	Notification = {
		BackgroundColor = Color3.fromRGB(40, 40, 40),
		TitleColor = Color3.fromRGB(255, 255, 255),
		MessageColor = Color3.fromRGB(200, 200, 200),
		InfoColor = Color3.fromRGB(85, 170, 255),
		SuccessColor = Color3.fromRGB(85, 255, 85),
		WarningColor = Color3.fromRGB(255, 255, 85),
		ErrorColor = Color3.fromRGB(255, 85, 85),
	},
}

-- Base UIElement Class
local UIElement = {}
UIElement.__index = UIElement

function UIElement.new(uiPlus, elementType, instanceType)
	local self = setmetatable({}, UIElement)
	
	self._uiPlus = uiPlus
	self._elementType = elementType
	self._instance = Instance.new(instanceType or "Frame")
	self._janitor = Janitor.new()
	self._connections = {}
	self._children = {}
	self._theme = {}
	
	-- Generate UID
	self.UID = Utility.GenerateUID(12)
	
	-- Default properties
	self.name = ""
	self.isEnabled = true
	self.isVisible = true
	self.isSelected = false
	self.locked = false
	self.parent = nil
	
	-- Visual defaults
	self.position = UDim2.new(0, 0, 0, 0)
	self.size = UDim2.new(0, 100, 0, 30)
	self.anchorPoint = Vector2.new(0, 0)
	self.zIndex = 1
	self.layoutOrder = 0
	
	self.backgroundColor = Color3.fromRGB(255, 255, 255)
	self.backgroundTransparency = 0
	self.borderColor = Color3.fromRGB(0, 0, 0)
	self.borderSize = 0
	self.cornerRadius = UDim.new(0, 0)
	
	self.text = ""
	self.textColor = Color3.fromRGB(0, 0, 0)
	self.textSize = 14
	self.textFont = DEFAULT_THEME.Font
	
	self.image = ""
	self.imageColor = Color3.fromRGB(255, 255, 255)
	self.imageTransparency = 0
	
	-- Events
	self.selected = Signal.new()
	self.deselected = Signal.new()
	self.clicked = Signal.new()
	self.hovered = Signal.new()
	self.unhovered = Signal.new()
	self.rightClicked = Signal.new()
	self.valueChanged = Signal.new()
	self.childAdded = Signal.new()
	self.childRemoved = Signal.new()
	
	-- Add to UI manager
	uiPlus._elements[self.UID] = self
	
	-- Cleanup on destroy
	self._janitor:Add(function()
		uiPlus._elements[self.UID] = nil
		for _, connection in ipairs(self._connections) do
			connection:Disconnect()
		end
		if self._instance then
			self._instance:Destroy()
		end
	end)
	
	return self
end

-- UIElement Methods
function UIElement:Destroy()
	self._janitor:Cleanup()
	self._uiPlus.ElementDestroyed:Fire(self)
end

function UIElement:SetParent(parent)
	if self.parent then
		-- Remove from old parent
		for i, child in ipairs(self.parent._children) do
			if child == self then
				table.remove(self.parent._children, i)
				break
			end
		end
	end
	
	self.parent = parent
	if parent then
		table.insert(parent._children, self)
		if self._instance then
			self._instance.Parent = parent._instance
		end
	end
	
	return self
end

function UIElement:AddChild(child)
	child:SetParent(self)
	self.childAdded:Fire(child)
	return self
end

function UIElement:RemoveChild(child)
	for i, c in ipairs(self._children) do
		if c == child then
			table.remove(self._children, i)
			child.parent = nil
			if child._instance then
				child._instance.Parent = nil
			end
			self.childRemoved:Fire(child)
			return true
		end
	end
	return false
end

function UIElement:SetVisible(visible)
	self.isVisible = visible
	if self._instance then
		self._instance.Visible = visible
	end
	return self
end

function UIElement:SetEnabled(enabled)
	self.isEnabled = enabled
	if self._instance then
		if self._instance:IsA("GuiButton") then
			self._instance.Active = enabled
		end
	end
	return self
end

function UIElement:SetPosition(position)
	self.position = position
	if self._instance then
		self._instance.Position = position
	end
	return self
end

function UIElement:SetSize(size)
	self.size = size
	if self._instance then
		self._instance.Size = size
	end
	return self
end

function UIElement:SetText(text)
	self.text = text
	if self._instance:IsA("TextLabel") or self._instance:IsA("TextButton") or self._instance:IsA("TextBox") then
		self._instance.Text = text
	end
	return self
end

function UIElement:SetImage(image)
	if type(image) == "number" then
		image = "rbxassetid://" .. tostring(image)
	end
	self.image = image
	if self._instance:IsA("ImageLabel") or self._instance:IsA("ImageButton") then
		self._instance.Image = image
	end
	return self
end

function UIElement:SetColor(color)
	self.backgroundColor = color
	if self._instance then
		self._instance.BackgroundColor3 = color
	end
	return self
end

function UIElement:SetTransparency(transparency)
	self.backgroundTransparency = transparency
	if self._instance then
		self._instance.BackgroundTransparency = transparency
	end
	return self
end

function UIElement:SetCornerRadius(radius)
	self.cornerRadius = radius
	local corners = self._instance:FindFirstChildOfClass("UICorner")
	if not corners then
		corners = Instance.new("UICorner")
		corners.Parent = self._instance
	end
	corners.CornerRadius = radius
	return self
end

function UIElement:TweenPosition(position, duration, easingStyle, easingDirection)
	duration = duration or 0.3
	easingStyle = easingStyle or Enum.EasingStyle.Quad
	easingDirection = easingDirection or Enum.EasingDirection.Out
	
	local tween = TweenService:Create(self._instance, TweenInfo.new(duration, easingStyle, easingDirection), {
		Position = position
	})
	tween:Play()
	self._janitor:Add(tween)
	return self
end

function UIElement:TweenSize(size, duration, easingStyle, easingDirection)
	duration = duration or 0.3
	easingStyle = easingStyle or Enum.EasingStyle.Quad
	easingDirection = easingDirection or Enum.EasingDirection.Out
	
	local tween = TweenService:Create(self._instance, TweenInfo.new(duration, easingStyle, easingDirection), {
		Size = size
	})
	tween:Play()
	self._janitor:Add(tween)
	return self
end

function UIElement:TweenColor(color, duration, easingStyle, easingDirection)
	duration = duration or 0.3
	easingStyle = easingStyle or Enum.EasingStyle.Quad
	easingDirection = easingDirection or Enum.EasingDirection.Out
	
	local tween = TweenService:Create(self._instance, TweenInfo.new(duration, easingStyle, easingDirection), {
		BackgroundColor3 = color
	})
	tween:Play()
	self._janitor:Add(tween)
	return self
end

function UIElement:BindEvent(event, callback)
	local signal = self[event]
	if signal and signal.Connect then
		local connection = signal:Connect(callback)
		table.insert(self._connections, connection)
		return connection
	end
	return nil
end

function UIElement:BindKey(keyCode, callback)
	local connection
	connection = UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == keyCode then
			callback()
		end
	end)
	table.insert(self._connections, connection)
	return connection
end

function UIElement:SetTooltip(text)
	-- Tooltip implementation would go here
	return self
end

function UIElement:SetOrder(order)
	self.layoutOrder = order
	if self._instance then
		self._instance.LayoutOrder = order
	end
	return self
end

function UIElement:SetPadding(padding)
	-- Padding implementation would go here
	return self
end

function UIElement:SetMargin(margin)
	-- Margin implementation would go here
	return self
end

function UIElement:SetFlexDirection(direction)
	if self._instance:IsA("UIListLayout") then
		self._instance.FillDirection = direction
	end
	return self
end

function UIElement:SetAlignment(horizontal, vertical)
	if self._instance:IsA("UIListLayout") then
		if horizontal then
			self._instance.HorizontalAlignment = horizontal
		end
		if vertical then
			self._instance.VerticalAlignment = vertical
		end
	elseif self._instance:IsA("TextLabel") or self._instance:IsA("TextButton") then
		if horizontal then
			self._instance.TextXAlignment = horizontal
		end
		if vertical then
			self._instance.TextYAlignment = vertical
		end
	end
	return self
end

function UIElement:SetOverflow(overflow)
	if self._instance:IsA("ScrollingFrame") then
		self._instance.ScrollingDirection = overflow
	end
	return self
end

function UIElement:SetScrollable(scrollable)
	if self._instance:IsA("ScrollingFrame") then
		self._instance.ScrollingEnabled = scrollable
	end
	return self
end

function UIElement:SetDraggable(draggable)
	-- Draggable implementation would go here
	return self
end

function UIElement:SetSelectable(selectable)
	if self._instance:IsA("TextButton") or self._instance:IsA("ImageButton") then
		self._instance.Selectable = selectable
	end
	return self
end

function UIElement:SetResizable(resizable)
	-- Resizable implementation would go here
	return self
end

function UIElement:SetClipsDescendants(clips)
	if self._instance then
		self._instance.ClipsDescendants = clips
	end
	return self
end

function UIElement:SetAutoSize(autoSize)
	if self._instance then
		self._instance.AutomaticSize = autoSize
	end
	return self
end

function UIElement:SetTheme(theme)
	self._theme = Utility.CopyTable(theme)
	self:Refresh()
	return self
end

function UIElement:Refresh()
	-- Apply theme properties
	if self._theme then
		-- Apply theme based on element type
		local elementTheme = self._uiPlus._theme[self._elementType] or {}
		
		if elementTheme.BackgroundColor then
			self:SetColor(elementTheme.BackgroundColor)
		end
		
		if elementTheme.TextColor then
			self.textColor = elementTheme.TextColor
			if self._instance:IsA("TextLabel") or self._instance:IsA("TextButton") then
				self._instance.TextColor3 = elementTheme.TextColor
			end
		end
		
		if elementTheme.CornerRadius then
			self:SetCornerRadius(elementTheme.CornerRadius)
		end
	end
	
	-- Update instance properties
	if self._instance then
		self._instance.Name = self.name
		self._instance.Visible = self.isVisible
		self._instance.Position = self.position
		self._instance.Size = self.size
		self._instance.AnchorPoint = self.anchorPoint
		self._instance.ZIndex = self.zIndex
		self._instance.LayoutOrder = self.layoutOrder
		self._instance.BackgroundColor3 = self.backgroundColor
		self._instance.BackgroundTransparency = self.backgroundTransparency
		self._instance.BorderColor3 = self.borderColor
		
		if self._instance:IsA("GuiObject") then
			self._instance.BorderSizePixel = self.borderSize
		end
		
		if self._instance:IsA("TextLabel") or self._instance:IsA("TextButton") or self._instance:IsA("TextBox") then
			self._instance.Text = self.text
			self._instance.TextColor3 = self.textColor
			self._instance.TextSize = self.textSize
			self._instance.FontFace = self.textFont
		end
		
		if self._instance:IsA("ImageLabel") or self._instance:IsA("ImageButton") then
			self._instance.Image = self.image
			self._instance.ImageColor3 = self.imageColor
			self._instance.ImageTransparency = self.imageTransparency
		end
	end
	
	return self
end

function UIElement:BringToFront()
	if self._instance then
		self._instance.ZIndex = 100
	end
	return self
end

function UIElement:SendToBack()
	if self._instance then
		self._instance.ZIndex = 1
	end
	return self
end

function UIElement:FindFirstChild(name)
	for _, child in ipairs(self._children) do
		if child.name == name then
			return child
		end
	end
	return nil
end

function UIElement:FindFirstChildOfClass(className)
	for _, child in ipairs(self._children) do
		if child._elementType == className then
			return child
		end
	end
	return nil
end

function UIElement:GetChildren()
	return Utility.CopyTable(self._children)
end

function UIElement:GetDescendants()
	local descendants = {}
	
	local function traverse(element)
		for _, child in ipairs(element._children) do
			table.insert(descendants, child)
			traverse(child)
		end
	end
	
	traverse(self)
	return descendants
end

function UIElement:GetAbsolutePosition()
	if self._instance then
		return self._instance.AbsolutePosition
	end
	return Vector2.new(0, 0)
end

function UIElement:GetAbsoluteSize()
	if self._instance then
		return self._instance.AbsoluteSize
	end
	return Vector2.new(0, 0)
end

function UIElement:IsDescendantOf(ancestor)
	local current = self.parent
	while current do
		if current == ancestor then
			return true
		end
		current = current.parent
	end
	return false
end

function UIElement:IsAncestorOf(descendant)
	return descendant:IsDescendantOf(self)
end

-- Specialized UI Elements
local Window = {} do
	setmetatable(Window, {__index = UIElement})
	
	function Window.new(uiPlus, title, size, position)
		local self = UIElement.new(uiPlus, "Window", "Frame")
		setmetatable(self, {__index = setmetatable({}, {__index = Window})})
		
		-- Window specific properties
		self.title = title or "Window"
		self.minimized = false
		self.maximized = false
		self.draggable = true
		self.resizable = true
		self.closeable = true
		self.minimizable = true
		self.maximizable = true
		
		-- Set default size and position
		size = size or UDim2.new(0, 400, 0, 300)
		position = position or UDim2.new(0.5, -200, 0.5, -150)
		
		self:SetSize(size)
		self:SetPosition(position)
		self:SetClipsDescendants(true)
		
		-- Apply window theme
		self:SetColor(uiPlus._theme.Window.BackgroundColor or DEFAULT_THEME.BackgroundColor)
		self:SetCornerRadius(uiPlus._theme.CornerRadius or DEFAULT_THEME.CornerRadius)
		
		-- Create title bar
		local titleBar = UIElement.new(uiPlus, "Frame", "Frame")
		titleBar:SetSize(UDim2.new(1, 0, 0, uiPlus._theme.Window.TitleBarHeight or 32))
		titleBar:SetColor(uiPlus._theme.Window.TitleBarColor or DEFAULT_THEME.Window.TitleBarColor)
		titleBar:SetCornerRadius(UDim.new(0, uiPlus._theme.CornerRadius or 6))
		titleBar._instance.Name = "TitleBar"
		
		-- Create title text
		local titleText = UIElement.new(uiPlus, "TextLabel", "TextLabel")
		titleText:SetText(self.title)
		titleText:SetPosition(UDim2.new(0, 10, 0, 0))
		titleText:SetSize(UDim2.new(1, -100, 1, 0))
		titleText.textColor = uiPlus._theme.Window.TitleTextColor or DEFAULT_THEME.Window.TitleTextColor
		titleText.textSize = uiPlus._theme.Window.TitleTextSize or 18
		titleText:SetAlignment(Enum.TextXAlignment.Left, Enum.TextYAlignment.Center)
		titleText._instance.Name = "TitleText"
		
		-- Create close button
		local closeButton = UIElement.new(uiPlus, "TextButton", "TextButton")
		closeButton:SetText("×")
		closeButton:SetPosition(UDim2.new(1, -35, 0, 0))
		closeButton:SetSize(UDim2.new(0, 30, 1, 0))
		closeButton:SetColor(Color3.fromRGB(220, 60, 60))
		closeButton.textSize = 20
		closeButton._instance.Name = "CloseButton"
		
		closeButton:BindEvent("clicked", function()
			self:Close()
		end)
		
		-- Add elements to window
		self:AddChild(titleBar)
		titleBar:AddChild(titleText)
		titleBar:AddChild(closeButton)
		
		-- Make window draggable
		if self.draggable then
			local dragging = false
			local dragStart, positionStart
			
			titleBar:BindEvent("clicked", function()
				dragging = true
				dragStart = UserInputService:GetMouseLocation()
				positionStart = self.position
				self:BringToFront()
			end)
			
			local connection = UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = UserInputService:GetMouseLocation() - dragStart
					self:SetPosition(UDim2.new(
						positionStart.X.Scale,
						positionStart.X.Offset + delta.X,
						positionStart.Y.Scale,
						positionStart.Y.Offset + delta.Y
					))
				end
			end)
			
			titleBar._janitor:Add(connection)
			
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
		end
		
		-- Add to windows list
		table.insert(uiPlus._windows, self)
		
		return self
	end
	
	function Window:Minimize()
		self.minimized = true
		self:SetSize(UDim2.new(self.size.X.Scale, self.size.X.Offset, 0, 32))
		return self
	end
	
	function Window:Maximize()
		self.maximized = true
		local screenSize = self._uiPlus:GetScreenSize()
		self:SetSize(UDim2.new(0, screenSize.X - 40, 0, screenSize.Y - 40))
		self:SetPosition(UDim2.new(0, 20, 0, 20))
		return self
	end
	
	function Window:Restore()
		self.minimized = false
		self.maximized = false
		self:SetSize(UDim2.new(0, 400, 0, 300))
		self:SetPosition(UDim2.new(0.5, -200, 0.5, -150))
		return self
	end
	
	function Window:Close()
		self:Destroy()
		-- Remove from windows list
		for i, window in ipairs(self._uiPlus._windows) do
			if window == self then
				table.remove(self._uiPlus._windows, i)
				break
			end
		end
		return self
	end
	
	function Window:SetTitle(title)
		self.title = title
		local titleText = self:FindFirstChild("TitleText")
		if titleText then
			titleText:SetText(title)
		end
		return self
	end
	
	function Window:SetTitleBar(visible)
		local titleBar = self:FindFirstChild("TitleBar")
		if titleBar then
			titleBar:SetVisible(visible)
		end
		return self
	end
	
	function Window:SetCloseButton(visible)
		local closeButton = self:FindFirstChild("CloseButton")
		if closeButton then
			closeButton:SetVisible(visible)
		end
		return self
	end
	
	function Window:SetMinimizeButton(visible)
		-- Implementation would go here
		return self
	end
	
	function Window:SetMaximizeButton(visible)
		-- Implementation would go here
		return self
	end
	
	function Window:SetIcon(icon)
		-- Implementation would go here
		return self
	end
	
	function Window:SetAccentColor(color)
		local titleBar = self:FindFirstChild("TitleBar")
		if titleBar then
			titleBar:SetColor(color)
		end
		return self
	end
end

local Button = {} do
	setmetatable(Button, {__index = UIElement})
	
	function Button.new(uiPlus, text, parent)
		local self = UIElement.new(uiPlus, "Button", "TextButton")
		setmetatable(self, {__index = setmetatable({}, {__index = Button})})
		
		-- Button specific properties
		self.buttonType = "Default"
		self.rounded = false
		self.icon = nil
		self.iconPosition = "Left"
		self.loading = false
		
		-- Set text
		self:SetText(text or "Button")
		
		-- Set default size
		self:SetSize(UDim2.new(0, 100, 0, 36))
		
		-- Apply button theme
		local buttonTheme = uiPlus._theme.Button.Default or DEFAULT_THEME.Button.Default
		self:SetColor(buttonTheme.BackgroundColor)
		self.textColor = buttonTheme.TextColor
		
		if self.rounded then
			self:SetCornerRadius(UDim.new(1, 0))
		else
			self:SetCornerRadius(uiPlus._theme.CornerRadius or DEFAULT_THEME.CornerRadius)
		end
		
		-- Center text
		self:SetAlignment(Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
		
		-- Add hover effects
		local originalColor = self.backgroundColor
		
		self:BindEvent("hovered", function()
			if not self.loading then
				self:TweenColor(originalColor:LinearInterpolate(Color3.new(1, 1, 1), 0.1), 0.2)
			end
		end)
		
		self:BindEvent("unhovered", function()
			if not self.loading then
				self:TweenColor(originalColor, 0.2)
			end
		end)
		
		-- Set parent if provided
		if parent then
			parent:AddChild(self)
		end
		
		return self
	end
	
	function Button:SetButtonType(buttonType)
		self.buttonType = buttonType
		local buttonTheme = self._uiPlus._theme.Button[buttonType] or DEFAULT_THEME.Button.Default
		self:SetColor(buttonTheme.BackgroundColor)
		self.textColor = buttonTheme.TextColor
		self:Refresh()
		return self
	end
	
	function Button:SetRounded(rounded)
		self.rounded = rounded
		if rounded then
			self:SetCornerRadius(UDim.new(1, 0))
		else
			self:SetCornerRadius(self._uiPlus._theme.CornerRadius or DEFAULT_THEME.CornerRadius)
		end
		return self
	end
	
	function Button:SetIcon(icon, position)
		self.icon = icon
		self.iconPosition = position or "Left"
		
		if icon then
			self:SetImage(icon)
			
			-- Adjust text position based on icon
			if self.iconPosition == "Left" then
				self:SetPadding(UDim.new(0, 30))
			elseif self.iconPosition == "Right" then
				self:SetPadding(UDim.new(0, 30))
			end
		end
		
		return self
	end
	
	function Button:SetLoading(loading)
		self.loading = loading
		if loading then
			-- Show loading animation
			self:SetText("Loading...")
			self:SetEnabled(false)
		else
			self:SetText(self.text)
			self:SetEnabled(true)
		end
		return self
	end
	
	function Button:Click()
		self.clicked:Fire(self:GetAbsolutePosition() + self:GetAbsoluteSize() / 2, "Programmatic")
		return self
	end
end

-- UIPlus Factory Methods
function UIPlus.new()
	local self = setmetatable({}, UIPlus)
	
	-- Initialize
	self._elements = {}
	self._windows = {}
	self._notifications = {}
	self._theme = Utility.CopyTable(DEFAULT_THEME)
	self._accentColor = DEFAULT_THEME.AccentColor
	self._font = DEFAULT_THEME.Font
	self._transparency = DEFAULT_THEME.BackgroundTransparency
	self._janitor = Janitor.new()
	
	-- Events
	self.ElementCreated = Signal.new()
	self.ElementDestroyed = Signal.new()
	self.ThemeChanged = Signal.new()
	self.NotificationCreated = Signal.new()
	self.HubCreated = Signal.new()
	
	-- Create main screen GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UIPlus"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	self._screenGui = screenGui
	self._janitor:Add(screenGui)
	
	return self
end

-- UIPlus Methods
function UIPlus:CreateWindow(title, size, position)
	local window = Window.new(self, title, size, position)
	window._instance.Parent = self._screenGui
	self.ElementCreated:Fire(window)
	return window
end

function UIPlus:CreateButton(text, parent)
	local button = Button.new(self, text, parent)
	self.ElementCreated:Fire(button)
	return button
end

function UIPlus:CreateTextBox(placeholder, parent)
	local textBox = UIElement.new(self, "TextBox", "TextBox")
	textBox:SetText("")
	textBox:SetSize(UDim2.new(0, 200, 0, 36))
	
	-- Apply theme
	local textBoxTheme = self._theme.TextBox or DEFAULT_THEME.TextBox
	textBox:SetColor(textBoxTheme.BackgroundColor)
	textBox.textColor = textBoxTheme.TextColor
	textBox:SetCornerRadius(self._theme.CornerRadius or DEFAULT_THEME.CornerRadius)
	
	-- Set placeholder
	if placeholder then
		textBox._instance.PlaceholderText = placeholder
		textBox._instance.PlaceholderColor3 = textBoxTheme.PlaceholderColor
	end
	
	if parent then
		parent:AddChild(textBox)
	end
	
	self.ElementCreated:Fire(textBox)
	return textBox
end

function UIPlus:CreateLabel(text, parent)
	local label = UIElement.new(self, "Label", "TextLabel")
	label:SetText(text)
	label:SetSize(UDim2.new(1, 0, 0, 20))
	label:SetAlignment(Enum.TextXAlignment.Left, Enum.TextYAlignment.Center)
	label.textColor = self._theme.TextColor or DEFAULT_THEME.TextColor
	label.textSize = self._theme.TextSize or DEFAULT_THEME.TextSize
	label.backgroundTransparency = 1
	
	if parent then
		parent:AddChild(label)
	end
	
	self.ElementCreated:Fire(label)
	return label
end

function UIPlus:CreateToggle(text, defaultValue, parent)
	local toggle = UIElement.new(self, "Toggle", "TextButton")
	toggle:SetText("  " .. (text or "Toggle"))
	toggle:SetSize(UDim2.new(1, 0, 0, 30))
	toggle:SetAlignment(Enum.TextXAlignment.Left, Enum.TextYAlignment.Center)
	toggle.backgroundTransparency = 1
	
	local value = defaultValue or false
	
	-- Create toggle visual
	local toggleFrame = UIElement.new(self, "Frame", "Frame")
	toggleFrame:SetSize(UDim2.new(0, 40, 0, 20))
	toggleFrame:SetPosition(UDim2.new(1, -45, 0.5, -10))
	toggleFrame:SetAnchorPoint(Vector2.new(1, 0.5))
	toggleFrame:SetCornerRadius(UDim.new(1, 0))
	
	local toggleKnob = UIElement.new(self, "Frame", "Frame")
	toggleKnob:SetSize(UDim2.new(0, 16, 0, 16))
	toggleKnob:SetPosition(UDim2.new(0, 2, 0.5, -8))
	toggleKnob:SetAnchorPoint(Vector2.new(0, 0.5))
	toggleKnob:SetCornerRadius(UDim.new(1, 0))
	toggleKnob:SetColor(self._theme.Toggle.KnobColor or DEFAULT_THEME.Toggle.KnobColor)
	
	toggle:AddChild(toggleFrame)
	toggleFrame:AddChild(toggleKnob)
	
	local function updateToggle()
		if value then
			toggleFrame:SetColor(self._theme.Toggle.OnColor or DEFAULT_THEME.Toggle.OnColor)
			toggleKnob:TweenPosition(UDim2.new(1, -18, 0.5, -8), 0.2)
		else
			toggleFrame:SetColor(self._theme.Toggle.OffColor or DEFAULT_THEME.Toggle.OffColor)
			toggleKnob:TweenPosition(UDim2.new(0, 2, 0.5, -8), 0.2)
		end
	end
	
	toggle:BindEvent("clicked", function()
		value = not value
		updateToggle()
		toggle.valueChanged:Fire(value, "User")
	end)
	
	updateToggle()
	
	if parent then
		parent:AddChild(toggle)
	end
	
	self.ElementCreated:Fire(toggle)
	return toggle
end

function UIPlus:CreateSlider(text, min, max, defaultValue, parent)
	local slider = UIElement.new(self, "Slider", "Frame")
	slider:SetSize(UDim2.new(1, 0, 0, 50))
	
	-- Create label
	local label = self:CreateLabel(text, slider)
	label:SetPosition(UDim2.new(0, 0, 0, 0))
	label:SetSize(UDim2.new(1, -50, 0, 20))
	
	-- Create value label
	local valueLabel = self:CreateLabel(tostring(defaultValue or min), slider)
	valueLabel:SetPosition(UDim2.new(1, -50, 0, 0))
	valueLabel:SetSize(UDim2.new(0, 50, 0, 20))
	valueLabel:SetAlignment(Enum.TextXAlignment.Right, Enum.TextYAlignment.Center)
	
	-- Create track
	local track = UIElement.new(self, "Frame", "Frame")
	track:SetSize(UDim2.new(1, 0, 0, 6))
	track:SetPosition(UDim2.new(0, 0, 1, -10))
	track:SetAnchorPoint(Vector2.new(0, 1))
	track:SetCornerRadius(UDim.new(1, 0))
	track:SetColor(self._theme.Slider.TrackColor or DEFAULT_THEME.Slider.TrackColor)
	
	-- Create fill
	local fill = UIElement.new(self, "Frame", "Frame")
	fill:SetSize(UDim2.new(0, 0, 1, 0))
	fill:SetCornerRadius(UDim.new(1, 0))
	fill:SetColor(self._theme.Slider.FillColor or DEFAULT_THEME.Slider.FillColor)
	
	-- Create knob
	local knob = UIElement.new(self, "Frame", "Frame")
	knob:SetSize(UDim2.new(0, 20, 0, 20))
	knob:SetPosition(UDim2.new(0, -10, 0.5, -10))
	knob:SetAnchorPoint(Vector2.new(0, 0.5))
	knob:SetCornerRadius(UDim.new(1, 0))
	knob:SetColor(self._theme.Slider.KnobColor or DEFAULT_THEME.Slider.KnobColor)
	
	slider:AddChild(track)
	track:AddChild(fill)
	track:AddChild(knob)
	
	local value = defaultValue or min
	local dragging = false
	
	local function updateSlider()
		local percentage = (value - min) / (max - min)
		fill:SetSize(UDim2.new(percentage, 0, 1, 0))
		knob:SetPosition(UDim2.new(percentage, -10, 0.5, -10))
		valueLabel:SetText(string.format("%.1f", value))
		slider.valueChanged:Fire(value, dragging and "User" or "Programmatic")
	end
	
	track:BindEvent("clicked", function(pos)
		dragging = true
		local absolutePos = track:GetAbsolutePosition()
		local absoluteSize = track:GetAbsoluteSize()
		local clickX = pos.X - absolutePos.X
		local percentage = math.clamp(clickX / absoluteSize.X, 0, 1)
		value = min + (max - min) * percentage
		updateSlider()
	end)
	
	knob:BindEvent("clicked", function()
		dragging = true
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mousePos = UserInputService:GetMouseLocation()
			local absolutePos = track:GetAbsolutePosition()
			local absoluteSize = track:GetAbsoluteSize()
			local clickX = mousePos.X - absolutePos.X
			local percentage = math.clamp(clickX / absoluteSize.X, 0, 1)
			value = min + (max - min) * percentage
			updateSlider()
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if dragging then
				dragging = false
				slider.valueChanged:Fire(value, "User")
			end
		end
	end)
	
	updateSlider()
	
	if parent then
		parent:AddChild(slider)
	end
	
	self.ElementCreated:Fire(slider)
	return slider
end

function UIPlus:CreateDropdown(text, options, parent)
	local dropdown = UIElement.new(self, "Dropdown", "TextButton")
	dropdown:SetSize(UDim2.new(1, 0, 0, 36))
	dropdown:SetAlignment(Enum.TextXAlignment.Left, Enum.TextYAlignment.Center)
	dropdown:SetCornerRadius(self._theme.CornerRadius or DEFAULT_THEME.CornerRadius)
	
	local dropdownTheme = self._theme.Dropdown or DEFAULT_THEME.Dropdown
	dropdown:SetColor(dropdownTheme.BackgroundColor)
	dropdown.textColor = self._theme.TextColor or DEFAULT_THEME.TextColor
	
	-- Create label
	local label = self:CreateLabel(text, dropdown)
	label:SetPosition(UDim2.new(0, 10, 0, 0))
	label:SetSize(UDim2.new(1, -40, 1, 0))
	label.backgroundTransparency = 1
	
	-- Create arrow
	local arrow = UIElement.new(self, "TextLabel", "TextLabel")
	arrow:SetText("▼")
	arrow:SetPosition(UDim2.new(1, -30, 0, 0))
	arrow:SetSize(UDim2.new(0, 20, 1, 0))
	arrow:SetAlignment(Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	arrow.textColor = self._theme.TextColor or DEFAULT_THEME.TextColor
	arrow.backgroundTransparency = 1
	
	dropdown:AddChild(arrow)
	
	-- Create options frame
	local optionsFrame = UIElement.new(self, "Frame", "Frame")
	optionsFrame:SetSize(UDim2.new(1, 0, 0, 0))
	optionsFrame:SetPosition(UDim2.new(0, 0, 1, 5))
	optionsFrame:SetClipsDescendants(true)
	optionsFrame:SetVisible(false)
	optionsFrame:SetCornerRadius(self._theme.CornerRadius or DEFAULT_THEME.CornerRadius)
	optionsFrame:SetColor(dropdownTheme.BackgroundColor)
	
	local optionsList = UIElement.new(self, "UIListLayout", "UIListLayout")
	optionsList:SetFlexDirection(Enum.FillDirection.Vertical)
	optionsList._instance.Parent = optionsFrame._instance
	
	dropdown:AddChild(optionsFrame)
	
	local selected = nil
	local open = false
	
	local function updateOptions()
		-- Clear existing options
		for _, child in ipairs(optionsFrame:GetChildren()) do
			child:Destroy()
		end
		
		-- Create new options
		local totalHeight = 0
		for i, option in ipairs(options) do
			local optionButton = self:CreateButton(option, optionsFrame)
			optionButton:SetSize(UDim2.new(1, -10, 0, 30))
			optionButton:SetPosition(UDim2.new(0, 5, 0, (i-1)*35))
			optionButton:SetAlignment(Enum.TextXAlignment.Left, Enum.TextYAlignment.Center)
			optionButton:SetPadding(UDim.new(0, 10))
			optionButton.backgroundTransparency = 0
			
			optionButton:BindEvent("clicked", function()
				selected = option
				label:SetText(option)
				dropdown.valueChanged:Fire(selected, "User")
				open = false
				optionsFrame:TweenSize(UDim2.new(1, 0, 0, 0), 0.2)
				task.wait(0.2)
				optionsFrame:SetVisible(false)
			end)
			
			totalHeight = totalHeight + 35
		end
		
		if open then
			optionsFrame:SetSize(UDim2.new(1, 0, 0, totalHeight))
		end
	end
	
	dropdown:BindEvent("clicked", function()
		open = not open
		if open then
			updateOptions()
			optionsFrame:SetVisible(true)
			optionsFrame:TweenSize(UDim2.new(1, 0, 0, #options * 35), 0.2)
			dropdown:BringToFront()
		else
			optionsFrame:TweenSize(UDim2.new(1, 0, 0, 0), 0.2)
			task.wait(0.2)
			optionsFrame:SetVisible(false)
		end
	end)
	
	updateOptions()
	
	if parent then
		parent:AddChild(dropdown)
	end
	
	self.ElementCreated:Fire(dropdown)
	return dropdown
end

function UIPlus:CreateColorPicker(text, defaultValue, parent)
	-- Color picker implementation would go here
	local colorPicker = UIElement.new(self, "ColorPicker", "Frame")
	
	if parent then
		parent:AddChild(colorPicker)
	end
	
	self.ElementCreated:Fire(colorPicker)
	return colorPicker
end

function UIPlus:CreateKeybind(text, defaultKey, parent)
	-- Keybind implementation would go here
	local keybind = UIElement.new(self, "Keybind", "TextButton")
	
	if parent then
		parent:AddChild(keybind)
	end
	
	self.ElementCreated:Fire(keybind)
	return keybind
end

function UIPlus:CreateTab(title, icon, parent)
	local tab = UIElement.new(self, "Tab", "TextButton")
	tab:SetText(title)
	tab:SetSize(UDim2.new(0, 100, 0, 40))
	tab:SetAlignment(Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	
	local tabTheme = self._theme.Tab or DEFAULT_THEME.Tab
	tab:SetColor(tabTheme.BackgroundColor)
	tab.textColor = tabTheme.TextColor
	tab:SetCornerRadius(UDim.new(0, 6))
	
	if icon then
		tab:SetImage(icon)
	end
	
	if parent then 		parent:AddChild(tab)
	end
	
	self.ElementCreated:Fire(tab)
	return tab
end

function UIPlus:CreateTabContainer(parent)
	local tabContainer = UIElement.new(self, "TabContainer", "Frame")
	tabContainer:SetSize(UDim2.new(1, 0, 1, 0))
	
	-- Create tab buttons container
	local tabButtons = UIElement.new(self, "Frame", "Frame")
	tabButtons:SetSize(UDim2.new(1, 0, 0, 40))
	tabButtons:SetColor(self._theme.SecondaryColor or DEFAULT_THEME.SecondaryColor)
	
	local tabList = UIElement.new(self, "UIListLayout", "UIListLayout")
	tabList:SetFlexDirection(Enum.FillDirection.Horizontal)
	tabList._instance.Padding = UDim.new(0, 5)
	
	-- Create content container
	local contentContainer = UIElement.new(self, "Frame", "Frame")
	contentContainer:SetSize(UDim2.new(1, 0, 1, -45))
	contentContainer:SetPosition(UDim2.new(0, 0, 0, 45))
	contentContainer:SetClipsDescendants(true)
	
	tabContainer:AddChild(tabButtons)
	tabButtons:AddChild(tabList)
	tabContainer:AddChild(contentContainer)
	
	local tabs = {}
	local selectedTab = nil
	
	function tabContainer:AddTab(tab)
		table.insert(tabs, tab)
		tabButtons:AddChild(tab)
		
		tab:BindEvent("clicked", function()
			tabContainer:SelectTab(tab)
		end)
		
		if #tabs == 1 then
			tabContainer:SelectTab(tab)
		end
		
		return tabContainer
	end
	
	function tabContainer:SelectTab(tabOrIndexOrTitle)
		local tabToSelect
		
		if type(tabOrIndexOrTitle) == "number" then
			tabToSelect = tabs[tabOrIndexOrTitle]
		elseif type(tabOrIndexOrTitle) == "string" then
			for _, t in ipairs(tabs) do
				if t.text == tabOrIndexOrTitle then
					tabToSelect = t
					break
				end
			end
		else
			tabToSelect = tabOrIndexOrTitle
		end
		
		if not tabToSelect or tabToSelect == selectedTab then
			return tabContainer
		end
		
		-- Deselect previous tab
		if selectedTab then
			local tabTheme = self._uiPlus._theme.Tab or DEFAULT_THEME.Tab
			selectedTab:SetColor(tabTheme.BackgroundColor)
			selectedTab.textColor = tabTheme.TextColor
			selectedTab:Refresh()
		end
		
		-- Select new tab
		selectedTab = tabToSelect
		local tabTheme = self._uiPlus._theme.Tab or DEFAULT_THEME.Tab
		selectedTab:SetColor(tabTheme.SelectedColor)
		selectedTab.textColor = tabTheme.SelectedTextColor
		selectedTab:Refresh()
		
		-- Clear content container and add tab content
		for _, child in ipairs(contentContainer:GetChildren()) do
			child:Destroy()
		end
		
		-- Move tab's children to content container
		for _, child in ipairs(selectedTab:GetChildren()) do
			contentContainer:AddChild(child)
		end
		
		tabContainer.tabChanged:Fire(selectedTab)
		return tabContainer
	end
	
	function tabContainer:GetTab(indexOrTitle)
		if type(indexOrTitle) == "number" then
			return tabs[indexOrTitle]
		elseif type(indexOrTitle) == "string" then
			for _, tab in ipairs(tabs) do
				if tab.text == indexOrTitle then
					return tab
				end
			end
		end
		return nil
	end
	
	if parent then
		parent:AddChild(tabContainer)
	end
	
	self.ElementCreated:Fire(tabContainer)
	return tabContainer
end

function UIPlus:CreateNotification(title, message, duration, parent)
	local notification = UIElement.new(self, "Notification", "Frame")
	notification:SetSize(UDim2.new(0, 300, 0, 100))
	notification:SetPosition(UDim2.new(1, -320, 1, -120))
	notification:SetCornerRadius(self._theme.CornerRadius or DEFAULT_THEME.CornerRadius)
	
	local notificationTheme = self._theme.Notification or DEFAULT_THEME.Notification
	notification:SetColor(notificationTheme.BackgroundColor)
	
	-- Create title
	local titleLabel = self:CreateLabel(title, notification)
	titleLabel:SetPosition(UDim2.new(0, 10, 0, 10))
	titleLabel:SetSize(UDim2.new(1, -20, 0, 24))
	titleLabel.textColor = notificationTheme.TitleColor
	titleLabel.textSize = 16
	titleLabel:SetAlignment(Enum.TextXAlignment.Left, Enum.TextYAlignment.Center)
	
	-- Create message
	local messageLabel = self:CreateLabel(message, notification)
	messageLabel:SetPosition(UDim2.new(0, 10, 0, 40))
	messageLabel:SetSize(UDim2.new(1, -20, 1, -50))
	messageLabel.textColor = notificationTheme.MessageColor
	messageLabel.textSize = 14
	messageLabel:SetAlignment(Enum.TextXAlignment.Left, Enum.TextYAlignment.Top)
	messageLabel.textWrapped = true
	
	-- Create close button
	local closeButton = self:CreateButton("×", notification)
	closeButton:SetPosition(UDim2.new(1, -30, 0, 5))
	closeButton:SetSize(UDim2.new(0, 25, 0, 25))
	closeButton:SetCornerRadius(UDim.new(1, 0))
	closeButton:SetColor(Color3.fromRGB(220, 60, 60))
	closeButton.textSize = 18
	
	closeButton:BindEvent("clicked", function()
		notification:Hide()
	end)
	
	notification.type = "Info"
	duration = duration or 5
	
	notification:Hide()
	
	if parent then
		parent:AddChild(notification)
	end
	
	-- Notification methods
	function notification:SetTitle(title)
		titleLabel:SetText(title)
		return self
	end
	
	function notification:SetMessage(message)
		messageLabel:SetText(message)
		return self
	end
	
	function notification:SetDuration(newDuration)
		duration = newDuration
		return self
	end
	
	function notification:SetType(notificationType)
		notification.type = notificationType
		local color
		
		if notificationType == "Success" then
			color = notificationTheme.SuccessColor
		elseif notificationType == "Warning" then
			color = notificationTheme.WarningColor
		elseif notificationType == "Error" then
			color = notificationTheme.ErrorColor
		else
			color = notificationTheme.InfoColor
		end
		
		notification:SetColor(color)
		return self
	end
	
	function notification:Show()
		notification:SetVisible(true)
		notification:TweenPosition(UDim2.new(1, -320, 1, -120), 0.3)
		
		if duration > 0 then
			task.delay(duration, function()
				if notification and notification.isVisible then
					notification:Hide()
				end
			end)
		end
		
		return self
	end
	
	function notification:Hide()
		notification:TweenPosition(UDim2.new(1, -320, 1, 100), 0.3)
		task.wait(0.3)
		notification:SetVisible(false)
		return self
	end
	
	function notification:Dismiss()
		notification:Hide()
		task.wait(0.3)
		notification:Destroy()
		return self
	end
	
	table.insert(self._notifications, notification)
	self.NotificationCreated:Fire(notification)
	self.ElementCreated:Fire(notification)
	
	return notification
end

function UIPlus:CreateFrame(parent)
	local frame = UIElement.new(self, "Frame", "Frame")
	frame:SetSize(UDim2.new(1, 0, 1, 0))
	frame:SetColor(self._theme.BackgroundColor or DEFAULT_THEME.BackgroundColor)
	frame:SetCornerRadius(self._theme.CornerRadius or DEFAULT_THEME.CornerRadius)
	
	if parent then
		parent:AddChild(frame)
	end
	
	self.ElementCreated:Fire(frame)
	return frame
end

function UIPlus:CreateScrollingFrame(parent)
	local scrollingFrame = UIElement.new(self, "ScrollingFrame", "ScrollingFrame")
	scrollingFrame:SetSize(UDim2.new(1, 0, 1, 0))
	scrollingFrame:SetColor(self._theme.BackgroundColor or DEFAULT_THEME.BackgroundColor)
	scrollingFrame:SetClipsDescendants(true)
	scrollingFrame:SetScrollable(true)
	scrollingFrame:SetOverflow(Enum.ScrollingDirection.XY)
	
	if parent then
		parent:AddChild(scrollingFrame)
	end
	
	self.ElementCreated:Fire(scrollingFrame)
	return scrollingFrame
end

function UIPlus:CreateListLayout(direction, parent)
	local listLayout = UIElement.new(self, "UIListLayout", "UIListLayout")
	listLayout:SetFlexDirection(direction or Enum.FillDirection.Vertical)
	listLayout._instance.Padding = UDim.new(0, self._theme.Padding or DEFAULT_THEME.Padding)
	
	if parent then
		parent:AddChild(listLayout)
	end
	
	self.ElementCreated:Fire(listLayout)
	return listLayout
end

function UIPlus:CreateGridLayout(cellSize, parent)
	local gridLayout = UIElement.new(self, "UIGridLayout", "UIGridLayout")
	gridLayout._instance.CellSize = cellSize or UDim2.new(0, 100, 0, 100)
	gridLayout._instance.CellPadding = UDim2.new(0, self._theme.Padding or DEFAULT_THEME.Padding, 0, self._theme.Padding or DEFAULT_THEME.Padding)
	
	if parent then
		parent:AddChild(gridLayout)
	end
	
	self.ElementCreated:Fire(gridLayout)
	return gridLayout
end

function UIPlus:CreatePadding(padding, parent)
	local paddingElement = UIElement.new(self, "UIPadding", "UIPadding")
	paddingElement._instance.PaddingBottom = padding
	paddingElement._instance.PaddingLeft = padding
	paddingElement._instance.PaddingRight = padding
	paddingElement._instance.PaddingTop = padding
	
	if parent then
		parent:AddChild(paddingElement)
	end
	
	self.ElementCreated:Fire(paddingElement)
	return paddingElement
end

-- Rayfield-Style Hub Methods
function UIPlus:CreateHub(title, size)
	local window = self:CreateWindow(title, size or UDim2.new(0, 500, 0, 400))
	
	-- Apply hub styling
	window:SetAccentColor(self._accentColor)
	
	-- Create content frame
	local content = self:CreateScrollingFrame(window)
	content:SetPosition(UDim2.new(0, 0, 0, 40))
	content:SetSize(UDim2.new(1, 0, 1, -40))
	
	-- Create layout
	local layout = self:CreateListLayout(Enum.FillDirection.Vertical, content)
	
	self.HubCreated:Fire(window)
	return window
end

function UIPlus:CreateTabbedHub(title, size)
	local window = self:CreateHub(title, size)
	
	-- Create tab container
	local tabContainer = self:CreateTabContainer(window)
	tabContainer:SetPosition(UDim2.new(0, 0, 0, 40))
	tabContainer:SetSize(UDim2.new(1, 0, 1, -40))
	
	return window, tabContainer
end

function UIPlus:CreateSection(title, parent)
	local section = self:CreateFrame(parent)
	section:SetSize(UDim2.new(1, 0, 0, 0))
	section:SetAutoSize(Enum.AutomaticSize.Y)
	section:SetColor(self._theme.SecondaryColor or DEFAULT_THEME.SecondaryColor)
	section:SetCornerRadius(self._theme.CornerRadius or DEFAULT_THEME.CornerRadius)
	
	if title then
		local titleLabel = self:CreateLabel(title, section)
		titleLabel:SetPosition(UDim2.new(0, 10, 0, 5))
		titleLabel:SetSize(UDim2.new(1, -20, 0, 20))
		titleLabel.textSize = 16
		titleLabel:SetAlignment(Enum.TextXAlignment.Left, Enum.TextYAlignment.Center)
		
		local layout = self:CreateListLayout(Enum.FillDirection.Vertical, section)
		layout._instance.Padding = UDim.new(0, 30, 0, 10)
	else
		local layout = self:CreateListLayout(Enum.FillDirection.Vertical, section)
		layout._instance.Padding = UDim.new(0, 10, 0, 10)
	end
	
	return section
end

function UIPlus:CreateDivider(parent)
	local divider = self:CreateFrame(parent)
	divider:SetSize(UDim2.new(1, -20, 0, 1))
	divider:SetPosition(UDim2.new(0, 10, 0, 0))
	divider:SetColor(self._theme.BorderColor or DEFAULT_THEME.BorderColor)
	divider:SetCornerRadius(UDim.new(0, 0))
	
	return divider
end

function UIPlus:CreateParagraph(text, parent)
	local paragraph = self:CreateLabel(text, parent)
	paragraph:SetSize(UDim2.new(1, -20, 0, 0))
	paragraph:SetAutoSize(Enum.AutomaticSize.Y)
	paragraph:SetPosition(UDim2.new(0, 10, 0, 0))
	paragraph.textWrapped = true
	paragraph.textSize = 14
	paragraph.textColor = Color3.fromRGB(200, 200, 200)
	
	return paragraph
end

function UIPlus:CreateTitle(text, parent)
	local title = self:CreateLabel(text, parent)
	title:SetSize(UDim2.new(1, -20, 0, 30))
	title:SetPosition(UDim2.new(0, 10, 0, 0))
	title.textSize = 24
	title:SetAlignment(Enum.TextXAlignment.Left, Enum.TextYAlignment.Center)
	
	return title
end

function UIPlus:CreateSubtitle(text, parent)
	local subtitle = self:CreateLabel(text, parent)
	subtitle:SetSize(UDim2.new(1, -20, 0, 24))
	subtitle:SetPosition(UDim2.new(0, 10, 0, 0))
	subtitle.textSize = 18
	subtitle.textColor = Color3.fromRGB(200, 200, 200)
	subtitle:SetAlignment(Enum.TextXAlignment.Left, Enum.TextYAlignment.Center)
	
	return subtitle
end

-- Utility Methods
function UIPlus:GetMousePosition()
	return UserInputService:GetMouseLocation()
end

function UIPlus:GetScreenSize()
	return workspace.CurrentCamera.ViewportSize
end

function UIPlus:CreateSignal()
	return Signal.new()
end

function UIPlus:CreateJanitor()
	return Janitor.new()
end

function UIPlus:CreateTween(instance, tweenInfo, properties)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	self._janitor:Add(tween)
	return tween
end

function UIPlus:Wait(seconds)
	task.wait(seconds)
end

function UIPlus:Debounce(name, callback, waitTime)
	local lastCall = 0
	return function(...)
		local now = tick()
		if now - lastCall >= (waitTime or 0.1) then
			lastCall = now
			callback(...)
		end
	end
end

function UIPlus:Round(number)
	return math.floor(number + 0.5)
end

function UIPlus:GenerateUID(length)
	return Utility.GenerateUID(length)
end

function UIPlus:CopyTable(table)
	return Utility.CopyTable(table)
end

-- Theme Methods
function UIPlus:SetTheme(theme)
	self._theme = Utility.CopyTable(theme)
	self.ThemeChanged:Fire(self._theme)
	
	-- Update all elements
	for _, element in pairs(self._elements) do
		element:SetTheme(self._theme)
	end
end

function UIPlus:GetTheme()
	return Utility.CopyTable(self._theme)
end

function UIPlus:SetAccentColor(color)
	self._accentColor = color
	self._theme.AccentColor = color
	
	-- Update theme for all elements
	self.ThemeChanged:Fire(self._theme)
	
	-- Update windows
	for _, window in ipairs(self._windows) do
		window:SetAccentColor(color)
	end
end

function UIPlus:GetAccentColor()
	return self._accentColor
end

function UIPlus:SetFont(font)
	self._font = font
	self._theme.Font = font
	self.ThemeChanged:Fire(self._theme)
end

function UIPlus:GetFont()
	return self._font
end

function UIPlus:SetTransparency(transparency)
	self._transparency = transparency
	self._theme.BackgroundTransparency = transparency
	self.ThemeChanged:Fire(self._theme)
end

function UIPlus:GetTransparency()
	return self._transparency
end

-- Notification Methods
function UIPlus:ShowNotification(title, message, duration, type)
	local notification = self:CreateNotification(title, message, duration)
	notification:SetType(type or "Info")
	notification:Show()
	return notification
end

function UIPlus:ShowInfo(title, message, duration)
	return self:ShowNotification(title, message, duration, "Info")
end

function UIPlus:ShowSuccess(title, message, duration)
	return self:ShowNotification(title, message, duration, "Success")
end

function UIPlus:ShowWarning(title, message, duration)
	return self:ShowNotification(title, message, duration, "Warning")
end

function UIPlus:ShowError(title, message, duration)
	return self:ShowNotification(title, message, duration, "Error")
end

-- Configuration
function UIPlus:SetDisplayOrder(order)
	if self._screenGui then
		self._screenGui.DisplayOrder = order
	end
end

function UIPlus:SetTopbarEnabled(enabled)
	-- Topbar specific functionality
	if self._screenGui then
		self._screenGui.Enabled = enabled
	end
end

function UIPlus:SetWatermark(text, enabled)
	-- Watermark implementation would go here
end

function UIPlus:SetKeybind(key, callback)
	local connection = UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == key then
			callback()
		end
	end)
	
	self._janitor:Add(connection)
	return connection
end

function UIPlus:SetToggleKey(key)
	-- Toggle key for showing/hiding UI
	self:SetKeybind(key, function()
		local anyVisible = false
		for _, window in ipairs(self._windows) do
			if window.isVisible then
				anyVisible = true
				break
			end
		end
		
		for _, window in ipairs(self._windows) do
			window:SetVisible(not anyVisible)
		end
	end)
end

-- Cleanup
function UIPlus:Destroy()
	self._janitor:Cleanup()
end

-- Example Usage Function
function UIPlus:CreateExampleHub()
	-- Create a tabbed hub like Rayfield
	local window, tabContainer = self:CreateTabbedHub("UIPlus Hub", UDim2.new(0, 600, 0, 500))
	window:SetPosition(UDim2.new(0.5, -300, 0.5, -250))
	
	-- Create tabs
	local homeTab = self:CreateTab("Home", "rbxassetid://7072721670")
	local settingsTab = self:CreateTab("Settings", "rbxassetid://7072722097")
	local aboutTab = self:CreateTab("About", "rbxassetid://7072722472")
	
	tabContainer:AddTab(homeTab)
	tabContainer:AddTab(settingsTab)
	tabContainer:AddTab(aboutTab)
	
	-- Home Tab Content
	local homeSection = self:CreateSection("Welcome", tabContainer:GetTab("Home"))
	homeSection:SetPosition(UDim2.new(0, 10, 0, 10))
	homeSection:SetSize(UDim2.new(1, -20, 0, 0))
	homeSection:SetAutoSize(Enum.AutomaticSize.Y)
	
	local welcomeText = self:CreateParagraph("Welcome to UIPlus! A comprehensive UI library for creating beautiful interfaces like Rayfield.", homeSection)
	
	local buttonSection = self:CreateSection("Buttons", tabContainer:GetTab("Home"))
	buttonSection:SetPosition(UDim2.new(0, 10, 0, 120))
	buttonSection:SetSize(UDim2.new(1, -20, 0, 0))
	buttonSection:SetAutoSize(Enum.AutomaticSize.Y)
	
	local defaultButton = self:CreateButton("Default Button", buttonSection)
	defaultButton:SetPosition(UDim2.new(0, 10, 0, 10))
	
	local primaryButton = self:CreateButton("Primary Button", buttonSection)
	primaryButton:SetPosition(UDim2.new(0, 120, 0, 10))
	primaryButton:SetButtonType("Primary")
	
	local dangerButton = self:CreateButton("Danger Button", buttonSection)
	dangerButton:SetPosition(UDim2.new(0, 240, 0, 10))
	dangerButton:SetButtonType("Danger")
	
	-- Settings Tab Content
	local settingsSection = self:CreateSection("Settings", tabContainer:GetTab("Settings"))
	settingsSection:SetPosition(UDim2.new(0, 10, 0, 10))
	settingsSection:SetSize(UDim2.new(1, -20, 0, 0))
	settingsSection:SetAutoSize(Enum.AutomaticSize.Y)
	
	local toggleSetting = self:CreateToggle("Enable Feature", true, settingsSection)
	toggleSetting:SetPosition(UDim2.new(0, 10, 0, 10))
	
	local sliderSetting = self:CreateSlider("Volume", 0, 100, 50, settingsSection)
	sliderSetting:SetPosition(UDim2.new(0, 10, 0, 50))
	
	local dropdownSetting = self:CreateDropdown("Theme", {"Dark", "Light", "Blue", "Red"}, settingsSection)
	dropdownSetting:SetPosition(UDim2.new(0, 10, 0, 110))
	
	-- About Tab Content
	local aboutSection = self:CreateSection("About UIPlus", tabContainer:GetTab("About"))
	aboutSection:SetPosition(UDim2.new(0, 10, 0, 10))
	aboutSection:SetSize(UDim2.new(1, -20, 0, 0))
	aboutSection:SetAutoSize(Enum.AutomaticSize.Y)
	
	local aboutText = self:CreateParagraph("UIPlus is a comprehensive UI library based on the TopbarPlus architecture. It provides all the tools needed to create beautiful, functional interfaces similar to Rayfield hubs.", aboutSection)
	
	local versionText = self:CreateParagraph("Version: 1.0.0", aboutSection)
	versionText:SetPosition(UDim2.new(0, 10, 0, 100))
	
	-- Show notification
	task.spawn(function()
		self:ShowInfo("Welcome", "UIPlus hub created successfully!")
	end)
	
	return window
end

-- Initialize and return UIPlus
local uiPlus = UIPlus.new()

-- Set up example keybinds
uiPlus:SetToggleKey(Enum.KeyCode.RightShift)

-- Export types and instance
return setmetatable(uiPlus, {
	__index = function(self, key)
		if UIPlus[key] then
			return UIPlus[key]
		end
		return nil
	end
}) :: UIPlus