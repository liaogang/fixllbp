## fixllbp

Lldb 在aslr下断点保存到文件，怎样重新加载

使用sbr.py的sbr命令在lldb下断点, 0000000101F1A620为文件地址,就是从ida或hopper直接看到的地址,　把0000000101F1A620记为fAdr_a

(lldb) sbr 0000000101F1A620 
Breakpoint 2: where = Aweme`std::__1::shared_ptr<Assimp::FBX::PropertyTable const> std::__1::shared_ptr<Assimp::FBX::PropertyTable const>::make_shared<Assimp::FBX::Element const&, std::__1::shared_ptr<Assimp::FBX::PropertyTable const>&>(Assimp::FBX::Element const&&&, std::__1::shared_ptr<Assimp::FBX::PropertyTable const>&&&) + 6405816, address = 0x0000000101fb2620

breakpoint write -f  br.json

把断点保存到文件中.

[{"Breakpoint" : {"BKPTOptions" : {"AutoContinue" : false,"ConditionText" : "","EnabledState" : true,"IgnoreCount" : 0,"OneShotState" : false},"BKPTResolver" : {"Options" : {"AddressOffset" : 32581600,"ModuleName" : "","Offset" : 0},"Type" : "Address"},"Hardware" : false,"SearchFilter" : {"Options" : {},"Type" : "Unconstrained"}}}]



值32581600记为brJson_a

要自动加载只需要改动br.json 文件中的二个地方

1. AddressOffset 一项 把原值加上常数C,　C与ASLR无关， C只与文件相关，同一个程序的C值相同

C = fAdr_a - brJson_a

这个C值就是section offset

1. ModuleName一项改为"Aweme"



lldb read breakpoint 的bug ，如果breakpoint下面没有"ConditionText" : ""会报错。需要手动加上.
