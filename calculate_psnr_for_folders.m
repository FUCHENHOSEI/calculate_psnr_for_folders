% Example usage
% calculate_psnr_for_folders('folder1_path', 'folder2_path');


function calculate_psnr_for_folders(folder1, folder2)

    % Get list of PNG files from the folders
    files1 = dir(fullfile(folder1, '*.png'));
    files2 = dir(fullfile(folder2, '*.png'));

    % Generate a file name based on the current date and time
    datetime_str = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    output_txt = ['results_', datetime_str, '.txt'];
    
    % Open file for writing results
    fid = fopen(output_txt, 'w');
    
    total_psnr = 0;
    total_ypsnr = 0;
    count = 0;

    % Loop through each file in folder1
    for i = 1:length(files1)
        % Check if the file also exists in folder2
        if ismember(files1(i).name, {files2.name})
            img1_path = fullfile(folder1, files1(i).name);
            img2_path = fullfile(folder2, files1(i).name);
            
            % Load images
            img1 = imread(img1_path);
            img2 = imread(img2_path);

            % Convert RGB to YCbCr
            ycbcr1 = rgb2ycbcr(img1);
            ycbcr2 = rgb2ycbcr(img2);
            
            % Calculate PSNR for the entire image
            psnr_value = compute_psnr(img1, img2);
            % Calculate PSNR for the Y component only
            y_psnr_value = compute_psnr(ycbcr1(:,:,1), ycbcr2(:,:,1));
            
            total_psnr = total_psnr + psnr_value;
            total_ypsnr = total_ypsnr + y_psnr_value;
            count = count + 1;

            fprintf(fid, 'Image: %s, PSNR: %f dB, Y-PSNR: %f dB\n', files1(i).name, psnr_value, y_psnr_value);
        end
    end

    % Write average PSNR to the file
    fprintf(fid, '\nAverage PSNR: %f dB\n', total_psnr / count);
    fprintf(fid, 'Average Y-PSNR: %f dB\n', total_ypsnr / count);

    % Close the file
    fclose(fid);
end

function psnr_value = compute_psnr(img1, img2)
    % Calculate MSE (Mean Square Error)
    mse = mean((double(img1) - double(img2)).^2, 'all');

    % If MSE is zero, PSNR is set to a very high value (infinite theoretically)
    if mse == 0
        psnr_value = 100;  % You can also use Inf
        return;
    end

    % Compute PSNR
    max_pixel_value = 255.0;  % for 8-bit images
    psnr_value = 20 * log10(max_pixel_value / sqrt(mse));
end

