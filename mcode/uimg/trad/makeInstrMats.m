function makeInstrMats
    CDataInstr=imread('message_too_fast.bmp');
    save('tooFast','CDataInstr');

    CDataInstr=imread('message_too_slow.bmp');
    save('tooSlow','CDataInstr');

    CDataInstr=imread('message_too_loud.bmp');
    save('tooLoud','CDataInstr');
    
    CDataInstr=imread('message_too_soft.bmp');
    save('tooSoft','CDataInstr');
    
    CDataInstr=imread('message_too_fast_loud.bmp');
    save('tooFastLoud','CDataInstr');       
    
    CDataInstr=imread('message_too_fast_soft.bmp');
    save('tooFastSoft','CDataInstr');       
    
    CDataInstr=imread('message_too_slow_loud.bmp');
    save('tooSlowLoud','CDataInstr');       
    
    CDataInstr=imread('message_too_slow_soft.bmp');
    save('tooSlowSoft','CDataInstr');  
    
    CDataInstr=imread('message_too_lombard.bmp');
    save('tooLombard','CDataInstr');      
return