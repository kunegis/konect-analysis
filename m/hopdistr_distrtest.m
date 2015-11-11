%
% Test which distributions fit the hop distribution.
%
% PARAMETERS 
%	$NETWORK
%
% INPUT 
%	dat/info.$NETWORK
%	dat/hopdistr2.$NETWORK
%
% OUTPUT 
%	dat/hopdistr_distrtest.$NETWORK.mat
%		.data.[distr-name]
%		the data of the fit as returned by
%		distrtest_plot()
%

network = getenv('NETWORK');

consts = konect_consts();  

info = read_info(network);
dat = load(sprintf('dat/hopdistr2.%s', network));

% Make a column vector
dat = dat(:)

% The number of nodes for which the hop distrubution was
% computed. This is the size of the network's largest connected
% component. 
n = round(sqrt(dat(end)));

values = (0 : (length(dat) - 1))';
counts = dat - [0; dat(1:end-1)];

types = distrtest_types();

data = struct(); 

for i = 1 : length(types)

    type = types{i}

    if ~strcmp(type, 'beta')

        ret = distrtest_multi(type, values, counts);

        data.(type) = ret;
    end
end

save(sprintf('dat/hopdistr_distrtest.%s.mat', network), '-v7.3', 'data');
