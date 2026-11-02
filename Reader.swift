import Cocoa
import Carbon

struct Item: Decodable { let id:Int; let type:String?; let by:String?; let title:String?; let text:String?; let score:Int?; let descendants:Int?; let kids:[Int]?; let deleted:Bool?; let dead:Bool? }
struct User: Decodable { let submitted:[Int]? }
final class Reader: NSObject, NSApplicationDelegate, NSSpeechSynthesizerDelegate {
 let usernameField=NSTextField(string:UserDefaults.standard.string(forKey:"hnUsername") ?? "")
 var window:NSWindow!; var status:NSStatusItem!; let speech=NSSpeechSynthesizer(); var stopHotkey:EventHotKeyRef?; var hotkey:EventHotKeyRef?; var keyHandler:EventHandlerRef?; var task:Task<Void,Never>?; var generation=0
 func applicationDidFinishLaunching(_ n:Notification) {
  speech.delegate=self
  status=NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength); status.button?.title="HN Reader"
  let menu=NSMenu(); menu.addItem(withTitle:"Read latest post (Command + 1)",action:#selector(read),keyEquivalent:"").target=self
  menu.addItem(withTitle:"Stop reading",action:#selector(stop),keyEquivalent:"").target=self
  menu.addItem(withTitle:"Enable keyboard shortcut",action:#selector(enable),keyEquivalent:"").target=self
  menu.addItem(withTitle:"Quit",action:#selector(quit),keyEquivalent:"").target=self; status.menu=menu
  window=NSWindow(contentRect:NSRect(x:0,y:0,width:560,height:340),styleMask:[.titled,.closable,.miniaturizable],backing:.buffered,defer:false)
  window.title="HN Accessible Reader — Mac only"; window.isReleasedWhenClosed=false
  let stack=NSStackView(); stack.orientation = .vertical; stack.spacing=18; stack.translatesAutoresizingMaskIntoConstraints=false
  let label=NSTextField(wrappingLabelWithString:"Press Command + 1 to read your latest Hacker News post. Press Escape to stop. The shortcut works globally without Input Monitoring permission.")
  stack.addArrangedSubview(label)
  let usernameLabel=NSTextField(labelWithString:"Hacker News username")
  stack.addArrangedSubview(usernameLabel)
  usernameField.placeholderString="Your Hacker News username"
  usernameField.setAccessibilityLabel("Hacker News username")
  stack.addArrangedSubview(usernameField)
  let save=NSButton(title:"Save username",target:self,action:#selector(saveUsername));stack.addArrangedSubview(save)

  for (title,action) in [("Read latest post",#selector(read)),("Stop reading",#selector(stop)),("Enable keyboard shortcut",#selector(enable))] {
   let button=NSButton(title:title,target:self,action:action); stack.addArrangedSubview(button)
  }
  window.contentView!.addSubview(stack)
  NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo:window.contentView!.leadingAnchor,constant:24),stack.trailingAnchor.constraint(equalTo:window.contentView!.trailingAnchor,constant:-24),stack.topAnchor.constraint(equalTo:window.contentView!.topAnchor,constant:20)])
  window.center(); window.makeKeyAndOrderFront(nil)
  NSEvent.addLocalMonitorForEvents(matching:.keyDown) { [weak self] event in
   if event.keyCode == 53 {self?.stop()}; return event
  }
  enable()
  if CommandLine.arguments.contains("--read") { read() }
 }
 @objc func quit(){ NSApp.terminate(nil) }
 func releaseStopKey(){ if let key=stopHotkey {UnregisterEventHotKey(key); stopHotkey=nil} }
 func speechSynthesizer(_ sender:NSSpeechSynthesizer,didFinishSpeaking finishedSpeaking:Bool){ releaseStopKey() }
 @objc func stop(){ generation += 1; task?.cancel(); task=nil; speech.stopSpeaking(); releaseStopKey(); status.button?.title="HN Reader" }
 @objc func enable(){
  if hotkey == nil {
   var spec=EventTypeSpec(eventClass:OSType(kEventClassKeyboard),eventKind:UInt32(kEventHotKeyPressed))
   InstallEventHandler(GetApplicationEventTarget(),{ _,event,ptr in
    let reader=Unmanaged<Reader>.fromOpaque(ptr!).takeUnretainedValue()
    var id=EventHotKeyID()
    if let event=event { GetEventParameter(event,EventParamName(kEventParamDirectObject),EventParamType(typeEventHotKeyID),nil,MemoryLayout<EventHotKeyID>.size,nil,&id) }
    if id.id == 2 { DispatchQueue.main.async{reader.stop()} }
    else {DispatchQueue.main.async{reader.read()}}
    return noErr
   },1,&spec,Unmanaged.passUnretained(self).toOpaque(),&keyHandler)
   let result=RegisterEventHotKey(UInt32(kVK_ANSI_1),UInt32(cmdKey),EventHotKeyID(signature:0x484E5244,id:1),GetApplicationEventTarget(),0,&hotkey)
   if result != noErr { status.button?.title="HN Reader: Shortcut unavailable"; return }
  }
  // No keyboard monitoring or accessibility permissions are requested.
 }
 @objc func saveUsername(){
  let name=usernameField.stringValue.trimmingCharacters(in:.whitespacesAndNewlines)
  guard validUsername(name) else {speech.startSpeaking("Enter a Hacker News username using letters, numbers, underscores or hyphens.");window.makeKeyAndOrderFront(nil);return}
  stop();UserDefaults.standard.set(name,forKey:"hnUsername");speech.startSpeaking("Username saved. Press Command and 1 to check your latest post.")
 }
 func fetch<T:Decodable>(_ path:String) async throws -> T {
  let url=URL(string:"https://hacker-news.firebaseio.com/v0/\(path).json")!
  var request=URLRequest(url:url,cachePolicy:.reloadIgnoringLocalCacheData,timeoutInterval:20); request.setValue("HNAccessibleReader/1.0",forHTTPHeaderField:"User-Agent")
  let (data,response)=try await URLSession.shared.data(for:request)
  guard (response as? HTTPURLResponse)?.statusCode==200 else{throw URLError(.badServerResponse)}
  return try JSONDecoder().decode(T.self,from:data)
 }
 func clean(_ html:String)->String {
  guard let data=html.data(using:.utf8), let value=try? NSAttributedString(data:data,options:[.documentType:NSAttributedString.DocumentType.html,.characterEncoding:String.Encoding.utf8.rawValue],documentAttributes:nil) else{return html}
  return value.string
 }
 @objc func read(){
  stop()
  let name=UserDefaults.standard.string(forKey:"hnUsername") ?? ""
  guard validUsername(name) else {window.makeKeyAndOrderFront(nil);NSApp.activate(ignoringOtherApps:true);speech.startSpeaking("First enter your Hacker News username and choose Save username.");return}
  let token=generation; status.button?.title="HN Reader: Checking"
  let result=RegisterEventHotKey(UInt32(kVK_Escape),0,EventHotKeyID(signature:0x484E5244,id:2),GetApplicationEventTarget(),0,&stopHotkey)
  if result != noErr {status.button?.title="HN Reader: Use Stop button"}
  task=Task { @MainActor in
   do {
    let user:User=try await fetch("user/\(name)")
    var latest:Item?
    for id in user.submitted ?? [] {
     try Task.checkCancellation(); let item:Item=try await fetch("item/\(id)")
     if item.type == "story" {latest=item; break}
    }
    guard let post=latest else {throw NSError(domain:"No public post found",code:1)}
    var lines=["Your latest Hacker News post. \(clean(post.title ?? "Untitled")). \(post.score ?? 0) points. \(post.descendants ?? 0) comments. Points are the displayed score, including the starting point."]
    if post.dead == true {lines.append("Hacker News marks this post as dead, so its visibility is restricted.")}
    if post.deleted == true {lines.append("This post has been deleted.")}
    var seen=Set<Int>(); var count=0
    func comments(_ ids:[Int],_ depth:Int) async throws {
     for id in ids {
      try Task.checkCancellation(); guard seen.insert(id).inserted else{continue}
      let c:Item=try await fetch("item/\(id)")
      if c.deleted != true && c.dead != true, let text=c.text {
       count += 1; lines.append("\(depth > 0 ? "Reply" : "Comment") by \(c.by ?? "unknown"). \(clean(text))")
      }
      try await comments(c.kids ?? [],depth+1)
     }
    }
    try await comments(post.kids ?? [],0)
    if count == 0 {lines.append("No readable comments yet.")}
    lines.append("End of comments.")
    guard token == generation else{return}; status.button?.title="HN Reader"
    let result=lines.joined(separator:"\n\n")
    let dir=FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("HN Accessible Reader")
    try? FileManager.default.createDirectory(at:dir,withIntermediateDirectories:true)
    try? result.write(to:dir.appendingPathComponent("last-reading.txt"),atomically:true,encoding:.utf8)
    speech.startSpeaking(result)
   } catch {
    guard token == generation else{return}; status.button?.title="HN Reader"; speech.startSpeaking("I couldn't check Hacker News. Please check your internet connection and try again.")
   }
  }
 }
}
func validUsername(_ name:String)->Bool {
 !name.isEmpty && name.range(of:"^[A-Za-z0-9_-]+$",options:.regularExpression) != nil
}
if CommandLine.arguments.contains("--self-test") {
 assert(validUsername("sample_user-1"));assert(!validUsername(""));assert(!validUsername("name/path"));assert(!validUsername("name?query"))
 let sample=Data("{\"id\":1,\"type\":\"story\",\"score\":4,\"descendants\":1}".utf8)
 let item=try! JSONDecoder().decode(Item.self,from:sample);assert(item.score==4 && item.descendants==1)
 print("PASS: username validation and public post status decoding");exit(0)
}
if CommandLine.arguments.contains("--check-api") {
 Task { @MainActor in
  do {let item:Item=try await Reader().fetch("item/8863");guard item.type=="story" && item.id==8863 else {exit(1)};print("PASS: official Hacker News API returned a real story");exit(0)}
  catch {print("API check failed: \(error)");exit(1)}
 }
 RunLoop.main.run()
}
let app=NSApplication.shared
let delegate=Reader()
app.delegate=delegate
app.setActivationPolicy(.accessory)
app.run()
