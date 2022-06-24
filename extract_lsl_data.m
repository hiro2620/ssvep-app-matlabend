function [raw_time, raw_eeg] = extract_lsl_data(lsl_time, lsl_eeg, sample_len)
% LSL�f�[�^���璼��sample_len���̃f�[�^�𒊏o

    lsl_len = length(lsl_eeg);
    
    % ���o�������f�[�^���̂ق������Ȃ��ꍇ�A�S�Ď��o��
    if lsl_len < sample_len
        raw_time = lsl_time;
        raw_eeg = lsl_eeg;
        
    % �����łȂ��ꍇ�Asample_len���̃f�[�^�����o��
    else
        extract_idx = lsl_len-sample_len+1 : lsl_len;
        raw_time = lsl_time(extract_idx);
        raw_eeg = lsl_eeg(:, extract_idx);
    end
end
