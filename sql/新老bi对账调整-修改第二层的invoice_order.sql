
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
update edw.invoice_order set true_finnal_ccuscode = 'ZD4205001' , true_finnal_ccusname2 = '�˲��и��ױ���Ժ' where sbvid = '1000000051' and db = 'UFDATA_588_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4205001' , true_finnal_ccusname2 = '�˲��и��ױ���Ժ' where sbvid = '1000000053' and db = 'UFDATA_588_2018';

-- ���տͻ����ˣ�ɽ������ҽѧ���鼼�����޹�˾�������и�Ů��ͯҽԺ�������и��ױ���Ժ��
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where sbvid = '1000004205' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where sbvid = '1000004206' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where sbvid = '1000004213' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where sbvid = '1000004550' and db = 'UFDATA_111_2018';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , true_finnal_ccusname2 = '�����и�Ů��ͯҽԺ�������и��ױ���Ժ��' where sbvid = '1000004551' and db = 'UFDATA_111_2018';

-- ���տͻ����ˣ������ж�ͯҽԺ������ʡ����ҽԺ
update edw.invoice_order set true_finnal_ccuscode = 'ZD4101003' , true_finnal_ccusname2 = '����ʡ����ҽԺ' where sbvid = '1000001337' and db = 'UFDATA_333_2018';

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
update edw.invoice_order set true_finnal_ccuscode = 'C0000789' , true_finnal_ccusname2 = '�����л�ɽ������ҽԺ' where sbvid = '1000005319' and db = 'UFDATA_111_2018';
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



