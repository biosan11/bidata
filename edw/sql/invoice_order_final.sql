-- ���տͻ����ˣ��人��������ҽѧ�Ƽ����޹�˾������Ϊ�˲��и��ױ���Ժ������ʡ���ױ���Ժ����
update edw.invoice_order set true_finnal_ccuscode = 'ZD4205001' , true_finnal_ccusname2 = '�˲��и��ױ���Ժ' where sbvid = '1000000064' and db = 'UFDATA_588_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4201001' , true_finnal_ccusname2 = '����ʡ���ױ���Ժ' where sbvid = '1000000065' and db = 'UFDATA_588_2018';

-- ���տͻ����ˣ�ɽ������ҽѧ���鼼�����޹�˾�������и�Ů��ͯҽԺ�������и��ױ���Ժ�����ٳ��и��ױ���Ժ
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where sbvid = '1000003437' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710001' , true_finnal_ccusname2 = '�ٳ��и��ױ���Ժ' where sbvid = '1000003442' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710001' , true_finnal_ccusname2 = '�ٳ��и��ױ���Ժ' where sbvid = '1000003443' and db = 'UFDATA_111_2018';

-- ���տͻ����ˣ��人��������ҽѧ�Ƽ����޹�˾������Ϊ�˲��и��ױ���Ժ������ʡ���ױ���Ժ����
-- update edw.invoice_order set true_finnal_ccuscode = 'ZD4205001' , true_finnal_ccusname2 = '�˲��и��ױ���Ժ' where sbvid = '1000000069' and db = 'UFDATA_588_2018';
-- update edw.invoice_order set true_finnal_ccuscode = 'ZD4201001' , true_finnal_ccusname2 = '����ʡ���ױ���Ժ' where sbvid = '1000000070' and db = 'UFDATA_588_2018';

-- ���տͻ����ˣ��ɶ������Ƽ����޹�˾������Ϊ�˲��и��ױ���Ժ
update edw.invoice_order set true_finnal_ccuscode = 'ZD4205001' , true_finnal_ccusname2 = '�˲��и��ױ���Ժ' where sbvid = '1000000051' and db = 'UFDATA_889_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4205001' , true_finnal_ccusname2 = '�˲��и��ױ���Ժ' where sbvid = '1000000053' and db = 'UFDATA_889_2018';

-- ���տͻ����ˣ�ɽ������ҽѧ���鼼�����޹�˾�������и�Ů��ͯҽԺ�������и��ױ���Ժ��
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where sbvid = '1000004205' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where sbvid = '1000004206' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where sbvid = '1000004213' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where sbvid = '1000004550' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where sbvid = '1000004551' and db = 'UFDATA_111_2018';

-- ���տͻ����ˣ������ж�ͯҽԺ������ʡ����ҽԺ
-- update edw.invoice_order set true_finnal_ccuscode = 'ZD4101003' , true_finnal_ccusname2 = '����ʡ����ҽԺ' where sbvid = '1000001337' and db = 'UFDATA_333_2018';

update edw.invoice_order set true_finnal_ccuscode = 'ZD3202005' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where year(ddate) <= 2018 and true_ccuscode = 'DL3202003';


-- ���տͻ����ˣ�ɽ������ҽѧ���鼼�����޹�˾�������и�Ů��ͯҽԺ�������и��ױ���Ժ��������ҽѧԺ��̨����ҽԺ��ɽ������ҽѧ���鼼�����޹�˾
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where sbvid = '1000004205' and db = 'UFDATA_111_2018';

-- �޸���ʷ�Ŀͻ��ǳɶ������Ƽ����޹�˾ 18����ǰ��ȫ����Ϊ�˱��и��ױ���Ժ
update edw.invoice_order set true_finnal_ccuscode = 'ZD5115002' , true_finnal_ccusname2 = '�˱��и��ױ���Ժ' where year(ddate) <= 2018 and true_ccuscode = 'DL5115001';

-- �޸���ʷ�Ŀͻ���ɽ������ҽѧ���鼼�����޹�˾ ,ɽ������ҽѧ���鼼�����޹�˾,ɽ������ҽѧ���鼼�����޹�˾
update edw.invoice_order set true_finnal_ccuscode = 'DL3710001' , true_finnal_ccusname2 = 'ɽ������ҽѧ���鼼�����޹�˾' where sbvid = '1000005460' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3706001' , true_finnal_ccusname2 = '����ҽѧԺ��̨����ҽԺ' where sbvid = '1000005459' and db = 'UFDATA_111_2018';

-- �޸���ʷ�Ŀͻ����人��ʥ��ҽѧ���������޹�˾ ,�����е�һ����ҽԺ
update edw.invoice_order set true_finnal_ccuscode = 'ZD4310003' , true_finnal_ccusname2 = '�����е�һ����ҽԺ' where sbvid = '1000008880' and db = 'UFDATA_111_2018';

-- ������ص���
update edw.invoice_order set true_finnal_ccuscode = 'ZD3412006' , true_finnal_ccusname2 = '����������ҽԺ' where sbvid = '1000005261' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004779' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004901' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004999' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004673' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004446' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004212' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004214' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003435' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003436' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4307003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004776' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3311015' , true_finnal_ccusname2 = '�ƺ��ظ��ױ����ƻ�������������' where sbvid = '1000004316' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4306001' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000005286' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4306001' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000005064' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3709006' , true_finnal_ccusname2 = '̩��������ҽԺ' where sbvid = '1000004459' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3709006' , true_finnal_ccusname2 = '̩��������ҽԺ' where sbvid = '1000004207' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3709006' , true_finnal_ccusname2 = '̩��������ҽԺ' where sbvid = '1000004209' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3709006' , true_finnal_ccusname2 = '̩��������ҽԺ' where sbvid = '1000004913' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3709006' , true_finnal_ccusname2 = '̩��������ҽԺ' where sbvid = '1000005310' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3709006' , true_finnal_ccusname2 = '̩��������ҽԺ' where sbvid = '1000005229' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3709006' , true_finnal_ccusname2 = '̩��������ҽԺ' where sbvid = '1000003852' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3709006' , true_finnal_ccusname2 = '̩��������ҽԺ' where sbvid = '1000003444' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3709006' , true_finnal_ccusname2 = '̩��������ҽԺ' where sbvid = '1000003452' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3709006' , true_finnal_ccusname2 = '̩��������ҽԺ' where sbvid = '1000003854' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3709006' , true_finnal_ccusname2 = '̩��������ҽԺ' where sbvid = '1000003855' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3709006' , true_finnal_ccusname2 = '̩��������ҽԺ' where sbvid = '1000003856' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3101020' , true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ' where sbvid = '1000005002' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3101020' , true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ' where sbvid = '1000005030' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3101020' , true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ' where sbvid = '1000005147' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3101020' , true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ' where sbvid = '1000004996' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3101020' , true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ' where sbvid = '1000004429' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3101020' , true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ' where sbvid = '1000004457' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3101020' , true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ' where sbvid = '1000004742' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3101020' , true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ' where sbvid = '1000004555' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3101020' , true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ' where sbvid = '1000004575' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3101020' , true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ' where sbvid = '1000004383' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3101020' , true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ' where sbvid = '1000004384' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3713031' , true_finnal_ccusname2 = '����������ҽԺ' where sbvid = '1000004941' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3713031' , true_finnal_ccusname2 = '����������ҽԺ' where sbvid = '1000003858' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3713031' , true_finnal_ccusname2 = '����������ҽԺ' where sbvid = '1000003860' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3713031' , true_finnal_ccusname2 = '����������ҽԺ' where sbvid = '1000003445' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3705001' , true_finnal_ccusname2 = '��Ӫ�и��ױ����ƻ�������������' where sbvid = '1000004868' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3714004' , true_finnal_ccusname2 = '����������ҽԺ' where sbvid = '1000003853' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3714004' , true_finnal_ccusname2 = '����������ҽԺ' where sbvid = '1000004506' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3714004' , true_finnal_ccusname2 = '����������ҽԺ' where sbvid = '1000004210' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3211002' , true_finnal_ccusname2 = '���е�������ҽԺ' where sbvid = '1000005065' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4501007' , true_finnal_ccusname2 = '�����е�һ����ҽԺ' where sbvid = '1000004151' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701019' , true_finnal_ccusname2 = 'ɽ����ѧ��³ҽԺ' where sbvid = '1000003431' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701019' , true_finnal_ccusname2 = 'ɽ����ѧ��³ҽԺ' where sbvid = '1000004811' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701019' , true_finnal_ccusname2 = 'ɽ����ѧ��³ҽԺ' where sbvid = '1000003849' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701019' , true_finnal_ccusname2 = 'ɽ����ѧ��³ҽԺ' where sbvid = '1000003850' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'DL3502007' , true_finnal_ccusname2 = '���ż���ҽ����е���޹�˾' where sbvid = '1000005162' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'DL3502007' , true_finnal_ccusname2 = '���ż���ҽ����е���޹�˾' where sbvid = '1000003430' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'DL3502007' , true_finnal_ccusname2 = '���ż���ҽ����е���޹�˾' where sbvid = '1000003848' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4310003' , true_finnal_ccusname2 = '�����е�һ����ҽԺ' where sbvid = '1000005029' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4310003' , true_finnal_ccusname2 = '�����е�һ����ҽԺ' where sbvid = '1000004474' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4310003' , true_finnal_ccusname2 = '�����е�һ����ҽԺ' where sbvid = '1000003440' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4310003' , true_finnal_ccusname2 = '�����е�һ����ҽԺ' where sbvid = '1000003441' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4310003' , true_finnal_ccusname2 = '�����е�һ����ҽԺ' where sbvid = '1000003746' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3502005' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003434' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3706028' , true_finnal_ccusname2 = '��̨ع諶�ҽԺ' where sbvid = '1000005265' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3503002' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003552' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3503002' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004069' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3503002' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003857' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3503002' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004911' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3201019' , true_finnal_ccusname2 = '�й������ž���һҽԺ' where sbvid = '1000004381' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3201019' , true_finnal_ccusname2 = '�й������ž���һҽԺ' where sbvid = '1000005048' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3201019' , true_finnal_ccusname2 = '�й������ž���һҽԺ' where sbvid = '1000005230' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3201019' , true_finnal_ccusname2 = '�й������ž���һҽԺ' where sbvid = '1000005231' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3201019' , true_finnal_ccusname2 = '�й������ž���һҽԺ' where sbvid = '1000003432' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3201019' , true_finnal_ccusname2 = '�й������ž���һҽԺ' where sbvid = '1000003438' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3707009' , true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ' where sbvid = '1000004035' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3707009' , true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ' where sbvid = '1000004576' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3707009' , true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ' where sbvid = '1000004578' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3707009' , true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ' where sbvid = '1000004591' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3707009' , true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ' where sbvid = '1000005363' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3707009' , true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ' where sbvid = '1000005163' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3707009' , true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ' where sbvid = '1000005164' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3707009' , true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ' where sbvid = '1000005254' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3707009' , true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ' where sbvid = '1000003317' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3707009' , true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ' where sbvid = '1000003447' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3707009' , true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ' where sbvid = '1000003798' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3707009' , true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ' where sbvid = '1000003800' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3206001' , true_finnal_ccusname2 = '��ͨ��ѧ����ҽԺ' where sbvid = '1000004195' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3206001' , true_finnal_ccusname2 = '��ͨ��ѧ����ҽԺ' where sbvid = '1000003846' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3716004' , true_finnal_ccusname2 = '����ҽѧԺ����ҽԺ' where sbvid = '1000004387' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3204001' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004475' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3204001' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004577' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3204001' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004208' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3204001' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000005183' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3204001' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003446' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3204001' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003799' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3202006' , true_finnal_ccusname2 = '�����л�ɽ������ҽԺ' where sbvid = '1000005319' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3205019' , true_finnal_ccusname2 = '�������������ҽԺ' where sbvid = '1000005330' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3205019' , true_finnal_ccusname2 = '�������������ҽԺ' where sbvid = '1000005332' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3205019' , true_finnal_ccusname2 = '�������������ҽԺ' where sbvid = '1000005340' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3205019' , true_finnal_ccusname2 = '�������������ҽԺ' where sbvid = '1000004639' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'DL3202003' , true_finnal_ccusname2 = '����ɽ�̼���ҽ����е���޹�˾' where sbvid = '1000003996' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'DL3202003' , true_finnal_ccusname2 = '����ɽ�̼���ҽ����е���޹�˾' where sbvid = '1000004940' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4209001' , true_finnal_ccusname2 = 'Т���и��ױ���Ժ' where sbvid = '1000000173' and db = 'UFDATA_222_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4303007' , true_finnal_ccusname2 = '��̶�ظ��ױ���Ժ' where sbvid = '1000005081' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4303007' , true_finnal_ccusname2 = '��̶�ظ��ױ���Ժ' where sbvid = '1000004665' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4303007' , true_finnal_ccusname2 = '��̶�ظ��ױ���Ժ' where sbvid = '1000004704' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701029' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003796' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD5101015' , true_finnal_ccusname2 = '�Ĵ�ʡ���ױ���Ժ' where sbvid = '1000000047' and db = 'UFDATA_889_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3706002' , true_finnal_ccusname2 = '��ɽ�����ױ���Ժ' where sbvid = '1000004216' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3505006' , true_finnal_ccusname2 = '����ҽ�ƴ�ѧ�����ڶ�ҽԺ' where sbvid = '1000004939' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003999' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004385' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004416' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004661' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004672' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004778' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004780' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004777' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003304' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003305' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003449' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003303' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4302004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003503' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3307010' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000003429' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3307010' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004371' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3307010' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004579' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3307010' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000004781' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3307010' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where sbvid = '1000005031' and db = 'UFDATA_111_2018';


update edw.invoice_order set true_finnal_ccuscode = 'ZD1501003' , true_finnal_ccusname2 = '���ɹ����������ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000033736';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_111_2018' and autoid = '1000033507';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000141';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000142';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000143';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000144';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000145';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000146';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000147';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000148';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000149';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000150';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000151';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000152';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000225';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000226';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000248';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000249';
update edw.invoice_order set true_finnal_ccuscode = 'ZD1301001' , true_finnal_ccusname2 = '�ӱ�ʡ���ױ�������' where db = 'UFDATA_168_2018' and autoid = '1000000250';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000023506';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033009';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033010';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033011';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033012';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033013';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033014';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033015';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033016';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033017';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033018';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033019';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033020';
update edw.invoice_order set true_finnal_ccuscode = 'DL1301003' , true_finnal_ccusname2 = 'ʯ��ׯ��ɸ��ҽ����е���޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000033508';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2201003' , true_finnal_ccusname2 = '����ʡ���ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000179';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2201003' , true_finnal_ccusname2 = '����ʡ���ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000180';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2201003' , true_finnal_ccusname2 = '����ʡ���ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000181';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2201003' , true_finnal_ccusname2 = '����ʡ���ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000182';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2201003' , true_finnal_ccusname2 = '����ʡ���ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000183';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2201003' , true_finnal_ccusname2 = '����ʡ���ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000184';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000053';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000054';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000055';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000085';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000086';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000123';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000153';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000154';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000178';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000229';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000230';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000231';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000232';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000233';
update edw.invoice_order set true_finnal_ccuscode = 'ZD2301001' , true_finnal_ccusname2 = '�������и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000234';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3101012' , true_finnal_ccusname2 = '�Ϻ��е�һ��Ӥ����Ժ' where db = 'UFDATA_111_2018' and autoid = '1000035516';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000007857';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000007858';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000007859';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000007860';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000007861';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000007862';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000010027';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000010029';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000010481';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000011291';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000011292';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000011293';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000011294';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000011295';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000012024';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000012335';
update edw.invoice_order set true_finnal_ccuscode = 'DL3208001' , true_finnal_ccusname2 = '�ϸ����й���ҽ�ƿƼ�ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000012543';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000014394';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000016569';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000018183';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020735';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020736';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020737';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020738';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020739';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020754';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020755';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020756';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020757';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020758';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020759';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020760';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020761';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020762';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020763';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020764';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020765';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020766';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020767';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020768';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020769';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020770';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020771';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020772';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020773';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020774';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020775';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000020776';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000021547';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000023426';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000023427';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000023428';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000023429';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000025500';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000026163';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000027680';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000027681';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000029299';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3208003' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000031876';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508001' , true_finnal_ccusname2 = '����ʡ�����е�һҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000032187';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028634';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028635';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028636';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028637';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028638';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028639';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028640';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028641';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028642';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028643';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028644';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028645';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028646';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000028647';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where db = 'UFDATA_111_2018' and autoid = '1000016575';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3706001' , true_finnal_ccusname2 = '����ҽѧԺ��̨����ҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000028718';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3706001' , true_finnal_ccusname2 = '����ҽѧԺ��̨����ҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000028719';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3706001' , true_finnal_ccusname2 = '����ҽѧԺ��̨����ҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000028720';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3706001' , true_finnal_ccusname2 = '����ҽѧԺ��̨����ҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000034700';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000021311';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000021312';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000021313';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000021314';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000021315';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000021316';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000021317';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000021318';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000021319';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000021998';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000021999';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000023920';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000023921';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000023922';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000023923';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000023924';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000023925';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000023926';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000024527';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000024528';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000024529';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000024530';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3701006' , true_finnal_ccusname2 = '�����ж�ͯҽԺ' where db = 'UFDATA_111_2018' and autoid = '1000027696';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4201001' , true_finnal_ccusname2 = '����ʡ���ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000027257';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4201001' , true_finnal_ccusname2 = '����ʡ���ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000027258';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4201001' , true_finnal_ccusname2 = '����ʡ���ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000027500';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4201001' , true_finnal_ccusname2 = '����ʡ���ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000027501';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4401001' , true_finnal_ccusname2 = '�㶫ʡ���ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000173';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4401001' , true_finnal_ccusname2 = '�㶫ʡ���ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000201';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4401001' , true_finnal_ccusname2 = '�㶫ʡ���ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000202';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4401001' , true_finnal_ccusname2 = '�㶫ʡ���ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000203';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4401001' , true_finnal_ccusname2 = '�㶫ʡ���ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000204';
update edw.invoice_order set true_finnal_ccuscode = 'DL4401005' , true_finnal_ccusname2 = '����ƥ��ó�����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000007855';
update edw.invoice_order set true_finnal_ccuscode = 'DL4401005' , true_finnal_ccusname2 = '����ƥ��ó�����޹�˾' where db = 'UFDATA_222_2018' and autoid = '1000003599';
update edw.invoice_order set true_finnal_ccuscode = 'DL4401005' , true_finnal_ccusname2 = '����ƥ��ó�����޹�˾' where db = 'UFDATA_222_2018' and autoid = '1000003606';
update edw.invoice_order set true_finnal_ccuscode = 'DL4401005' , true_finnal_ccusname2 = '����ƥ��ó�����޹�˾' where db = 'UFDATA_222_2018' and autoid = '1000003607';
update edw.invoice_order set true_finnal_ccuscode = 'DL4401005' , true_finnal_ccusname2 = '����ƥ��ó�����޹�˾' where db = 'UFDATA_222_2018' and autoid = '1000003945';
update edw.invoice_order set true_finnal_ccuscode = 'DL4401005' , true_finnal_ccusname2 = '����ƥ��ó�����޹�˾' where db = 'UFDATA_222_2018' and autoid = '1000003946';
update edw.invoice_order set true_finnal_ccuscode = 'DL4401005' , true_finnal_ccusname2 = '����ƥ��ó�����޹�˾' where db = 'UFDATA_222_2018' and autoid = '1000003947';
update edw.invoice_order set true_finnal_ccuscode = 'DL4401005' , true_finnal_ccusname2 = '����ƥ��ó�����޹�˾' where db = 'UFDATA_222_2018' and autoid = '1000003948';
update edw.invoice_order set true_finnal_ccuscode = 'DL4401005' , true_finnal_ccusname2 = '����ƥ��ó�����޹�˾' where db = 'UFDATA_222_2018' and autoid = '1000004313';
update edw.invoice_order set true_finnal_ccuscode = 'DL4401005' , true_finnal_ccusname2 = '����ƥ��ó�����޹�˾' where db = 'UFDATA_222_2018' and autoid = '1000004314';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4401006' , true_finnal_ccusname2 = '�����и�ӤҽԺ�������и��ױ���Ժ��' where db = 'UFDATA_168_2018' and autoid = '1000000103';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4401006' , true_finnal_ccusname2 = '�����и�ӤҽԺ�������и��ױ���Ժ��' where db = 'UFDATA_168_2018' and autoid = '1000000104';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4401006' , true_finnal_ccusname2 = '�����и�ӤҽԺ�������и��ױ���Ժ��' where db = 'UFDATA_168_2018' and autoid = '1000000105';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4412002' , true_finnal_ccusname2 = '�����ж��������ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000030283';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4412002' , true_finnal_ccusname2 = '�����ж��������ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000030284';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4412002' , true_finnal_ccusname2 = '�����ж��������ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000030285';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4412002' , true_finnal_ccusname2 = '�����ж��������ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000030286';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4412002' , true_finnal_ccusname2 = '�����ж��������ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000030287';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4412002' , true_finnal_ccusname2 = '�����ж��������ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000030288';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4412002' , true_finnal_ccusname2 = '�����ж��������ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000030289';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4412002' , true_finnal_ccusname2 = '�����ж��������ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000030455';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4412002' , true_finnal_ccusname2 = '�����ж��������ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000030456';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3607001' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000174';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3607001' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000185';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3607001' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_168_2018' and autoid = '1000000186';
update edw.invoice_order set true_finnal_ccuscode = 'ZD6104002' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000034918';
update edw.invoice_order set true_finnal_ccuscode = 'ZD6101008' , true_finnal_ccusname2 = '�����и��ױ���Ժ' where db = 'UFDATA_111_2018' and autoid = '1000029148';
update edw.invoice_order set true_finnal_ccuscode = 'DL6101001' , true_finnal_ccusname2 = '������Դ��������Լ����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000015770';
update edw.invoice_order set true_finnal_ccuscode = 'DL6101001' , true_finnal_ccusname2 = '������Դ��������Լ����޹�˾' where db = 'UFDATA_111_2018' and autoid = '1000027397';
-- update edw.invoice_order set true_finnal_ccuscode = 'DL4201003' , true_finnal_ccusname2 = '�人��������ҽѧ�Ƽ����޹�˾' where true_ccuscode = 'DL4201003';
update edw.invoice_order set true_finnal_ccuscode = 'DL4310001' , true_finnal_ccusname2 = '�人��ʥ��ҽѧ���������޹�˾' where true_ccuscode = 'DL4310001';

-- 0117���տͻ�����
update edw.invoice_order set true_finnal_ccusname2 = '��Ǩ�и��ױ���Ժ',true_finnal_ccuscode = 'ZD3213005' where true_ccuscode = 'DL3213004' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '��Ǩ������ҽԺ',true_finnal_ccuscode = 'ZD3213008' where true_ccuscode = 'DL3213005' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = 'ɽ����ѧ������ֳҽԺ',true_finnal_ccuscode = 'ZD3701018' where true_ccuscode = 'DL3701017' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '���ݾ���ҽԺ',true_finnal_ccuscode = 'ZD3205012' where true_ccuscode = 'DL3205007' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�����Ҷ�����ҽԺ',true_finnal_ccuscode = 'ZD1101020' where true_ccuscode = 'DL1101036' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = 'ͭ���и��ױ���Ժ',true_finnal_ccuscode = 'ZD3407001' where true_ccuscode = 'DL3401001' and year(ddate) <= 2018;
-- update edw.invoice_order set true_finnal_ccusname2 = '��������ҽѧ������',true_finnal_ccuscode = 'ZD1101021' where true_ccuscode = 'DL1101002' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3701029' where true_ccuscode = 'DL3701001' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�׶�ҽ�ƴ�ѧ������������ҽԺ',true_finnal_ccuscode = 'ZD1101014' where true_ccuscode = 'DL1101013' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3504001' where true_ccuscode = 'DL3504001' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�����е�һҽԺ',true_finnal_ccuscode = 'ZD3501007' where true_ccuscode = 'DL3501009' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '����ҽ�ƴ�ѧ������ɸ���о���',true_finnal_ccuscode = 'ZD4501002' where true_ccuscode = 'DL4501001' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD4302004' where true_ccuscode = 'DL4302001' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�㽭ʡ����ҽԺ',true_finnal_ccuscode = 'ZD3301041' where true_ccuscode = 'DL3301027' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�����и�����ҽԺ(�����и��ױ���Ժ)',true_finnal_ccuscode = 'ZD3301014' where true_ccuscode = 'DL3301016' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '����ʡ���ױ���Ժ���Ϸ��и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3401002' where true_ccuscode = 'DL3401002' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '����ʡ���ױ���Ժ',true_finnal_ccuscode = 'ZD4101002' where true_ccuscode = 'DL4101001' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '̩��������ҽԺ',true_finnal_ccuscode = 'ZD3709006' where true_ccuscode = 'DL3709001' and year(ddate) <= 2018;
-- update edw.invoice_order set true_finnal_ccusname2 = '���ݺ�ŵҽ�����ﲿ',true_finnal_ccuscode = 'ZD3301044' where true_ccuscode = 'DL3301003' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = 'ɽ��ʡ�ƻ�������ѧ�����о���',true_finnal_ccuscode = 'ZD3701022' where true_ccuscode = 'DL3701008' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '��Ӫ�и��ױ����ƻ�������������',true_finnal_ccuscode = 'ZD3705001' where true_ccuscode = 'DL3705004' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '����������ҽԺ',true_finnal_ccuscode = 'ZD3714004' where true_ccuscode = 'DL3714002' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3701007' where true_ccuscode = 'DL3701011' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = 'ɽ����ѧ��³ҽԺ',true_finnal_ccuscode = 'ZD3701019' where true_ccuscode = 'DL3701012' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '����ʡ���ױ���Ժ',true_finnal_ccuscode = 'ZD6201001' where true_ccuscode = 'DL6301002' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '���Ŵ�ѧ������һҽԺ',true_finnal_ccuscode = 'ZD3502002' where true_ccuscode = 'DL3502005' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '��ž�һ����ҽԺ',true_finnal_ccuscode = 'ZD3502001' where true_ccuscode = 'DL3502007' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = 'Ϋ��������ҽԺ',true_finnal_ccuscode = 'ZD3707010' where true_ccuscode = 'DL3707002' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD4502001' where true_ccuscode = 'DL4502001' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = 'Ϋ���и��ױ���Ժ',true_finnal_ccuscode = 'ZD3707009' where true_ccuscode = 'DL3707004' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�Ϻ�����ҽѧ������',true_finnal_ccuscode = 'ZD3101008' where true_ccuscode = 'DL3101035' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�⽭����һ����ҽԺ',true_finnal_ccuscode = 'ZD3205022' where true_ccuscode = 'DL3205005' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '��̶�ظ��ױ���Ժ',true_finnal_ccuscode = 'ZD4303007' where true_ccuscode = 'DL4303002' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '����ҽ�ƴ�ѧ������ͯҽԺ',true_finnal_ccuscode = 'ZD5101019' where true_ccuscode = 'DL5001002' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD4304004' where true_ccuscode = 'DL4301011' and year(ddate) <= 2018;
-- update edw.invoice_order set true_finnal_ccusname2 = '�Ϻ���������',true_finnal_ccuscode = 'ZD3101021' where true_ccuscode = 'DL3101007' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3210003' where true_ccuscode = 'DL3301020' and year(ddate) <= 2018;
-- update edw.invoice_order set true_finnal_ccusname2 = '��������ҽѧ������',true_finnal_ccuscode = 'ZD1101021' where true_ccuscode = 'DL1101002' and year(ddate) <= 2018;
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3202005' where true_ccuscode = 'DL3202003' and year(ddate) <= 2018;

update edw.invoice_order set true_finnal_ccusname2 = '�㽭ʡ����ҽԺ',true_finnal_ccuscode = 'ZD3301041' where db = 'UFDATA_111_2018' and autoid = '1000034931';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3307010' where db = 'UFDATA_111_2018' and autoid = '1000007866';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3307010' where db = 'UFDATA_111_2018' and autoid = '1000007867';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3307010' where db = 'UFDATA_111_2018' and autoid = '1000007868';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3307010' where db = 'UFDATA_111_2018' and autoid = '1000008725';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3307010' where db = 'UFDATA_111_2018' and autoid = '1000008726';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3307010' where db = 'UFDATA_111_2018' and autoid = '1000008727';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3307010' where db = 'UFDATA_111_2018' and autoid = '1000008728';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3307010' where db = 'UFDATA_111_2018' and autoid = '1000009638';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3307010' where db = 'UFDATA_111_2018' and autoid = '1000008729';

update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000007857';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000007858';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000007859';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000007860';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000007861';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000007862';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000010027';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000010029';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000010481';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000011291';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000011292';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000011293';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000011294';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000011295';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000012335';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000012024';
update edw.invoice_order set true_finnal_ccusname2 = '�����и��ױ���Ժ',true_finnal_ccuscode = 'ZD3208003' where db = 'UFDATA_111_2018' and autoid = '1000012543';

update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000014396';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000012334';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000016576';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023231';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023232';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023233';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023234';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023235';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023236';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023237';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023238';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023239';

update edw.invoice_order set true_finnal_ccusname2 = '���ɹ����������ױ���Ժ',true_finnal_ccuscode = 'ZD1501003' where db = 'UFDATA_111_2018' and autoid = '1000033009';
update edw.invoice_order set true_finnal_ccusname2 = '���ɹ����������ױ���Ժ',true_finnal_ccuscode = 'ZD1501003' where db = 'UFDATA_111_2018' and autoid = '1000033010';
update edw.invoice_order set true_finnal_ccusname2 = '���ɹ����������ױ���Ժ',true_finnal_ccuscode = 'ZD1501003' where db = 'UFDATA_111_2018' and autoid = '1000033011';
update edw.invoice_order set true_finnal_ccusname2 = '���ɹ����������ױ���Ժ',true_finnal_ccuscode = 'ZD1501003' where db = 'UFDATA_111_2018' and autoid = '1000033012';
update edw.invoice_order set true_finnal_ccusname2 = '���ɹ����������ױ���Ժ',true_finnal_ccuscode = 'ZD1501003' where db = 'UFDATA_111_2018' and autoid = '1000033013';
update edw.invoice_order set true_finnal_ccusname2 = '���ɹ����������ױ���Ժ',true_finnal_ccuscode = 'ZD1501003' where db = 'UFDATA_111_2018' and autoid = '1000033014';
update edw.invoice_order set true_finnal_ccusname2 = '���ɹ����������ױ���Ժ',true_finnal_ccuscode = 'ZD1501003' where db = 'UFDATA_111_2018' and autoid = '1000033015';
update edw.invoice_order set true_finnal_ccusname2 = '���ɹ����������ױ���Ժ',true_finnal_ccuscode = 'ZD1501003' where db = 'UFDATA_111_2018' and autoid = '1000033016';
update edw.invoice_order set true_finnal_ccusname2 = '���ɹ����������ױ���Ժ',true_finnal_ccuscode = 'ZD1501003' where db = 'UFDATA_111_2018' and autoid = '1000033017';
update edw.invoice_order set true_finnal_ccusname2 = '���ɹ����������ױ���Ժ',true_finnal_ccuscode = 'ZD1501003' where db = 'UFDATA_111_2018' and autoid = '1000033018';
update edw.invoice_order set true_finnal_ccusname2 = '���ɹ����������ױ���Ժ',true_finnal_ccuscode = 'ZD1501003' where db = 'UFDATA_111_2018' and autoid = '1000033019';
update edw.invoice_order set true_finnal_ccusname2 = '���ɹ����������ױ���Ժ',true_finnal_ccuscode = 'ZD1501003' where db = 'UFDATA_111_2018' and autoid = '1000033020';

update edw.invoice_order set true_finnal_ccusname2 = '�����е�һ����ҽԺ',true_finnal_ccuscode = 'ZD4310003' where db = 'UFDATA_222_2018' and autoid = '1000001513';
update edw.invoice_order set true_finnal_ccusname2 = '�����е�һ����ҽԺ',true_finnal_ccuscode = 'ZD4310003' where db = 'UFDATA_222_2018' and autoid = '1000002764';
update edw.invoice_order set true_finnal_ccusname2 = '�����е�һ����ҽԺ',true_finnal_ccuscode = 'ZD4310003' where db = 'UFDATA_222_2018' and autoid = '1000002985';
update edw.invoice_order set true_finnal_ccusname2 = '�����е�һ����ҽԺ',true_finnal_ccuscode = 'ZD4310003' where db = 'UFDATA_222_2018' and autoid = '1000003952';

update edw.invoice_order set true_finnal_ccusname2 = '�Ϻ��ж���ҽѧ�о���',true_finnal_ccuscode = 'ZD3101015' where db = 'UFDATA_111_2018' and autoid = '1000019402';
update edw.invoice_order set true_finnal_ccusname2 = '�Ϻ��ж�ͯҽԺ',true_finnal_ccuscode = 'ZD3101016' where db = 'UFDATA_111_2018' and sbvid = '1000006731';
update edw.invoice_order set true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ',true_finnal_ccuscode = 'ZD3101020' where db = 'UFDATA_111_2018' and sbvid = '1000006038';
update edw.invoice_order set true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ',true_finnal_ccuscode = 'ZD3101020' where db = 'UFDATA_111_2018' and sbvid = '1000004061';
update edw.invoice_order set true_finnal_ccusname2 = '�й���������ʺ�ƽ���ױ���Ժ',true_finnal_ccuscode = 'ZD3101020' where db = 'UFDATA_111_2018' and autoid = '1000020934';

update edw.invoice_order set true_finnal_ccusname2 = '�����ж��������ױ���Ժ',true_finnal_ccuscode = 'ZD4412002' where db = 'UFDATA_111_2018' and autoid = '1000007855';
-- ������ʵɽ�������޸�Ϊ�����и�Ů��ͯҽԺ�������и��ױ���Ժ��
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000012334';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000016576';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023231';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023232';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023233';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023234';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023235';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023236';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023237';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023238';
update edw.invoice_order set true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��',true_finnal_ccuscode = 'ZD3710003' where db = 'UFDATA_111_2018' and autoid = '1000023239';




-- ���߽���ṩʵ�ʽ����޸�
update edw.invoice_order set true_finnal_ccusname2 = '�������������ҽԺ',true_finnal_ccuscode = 'ZD3205019' where db = 'UFDATA_111_2018' and autoid = '1000013852';










