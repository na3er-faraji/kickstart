const path = require('path')
const solc = require('solc')
const fs = require('fs-extra')

const contractFileName = "Campaign.sol";
const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

const campaignPath = path.resolve(__dirname, 'contracts', contractFileName);
const source = fs.readFileSync(campaignPath, 'utf8');

const input = {
    language: "Solidity",
    sources: {
        [contractFileName]: {
            content: source
        }
    },
    settings: {
        metadata: {
            useLiteralContent: true,
        },
        outputSelection: {
            "*": {
                "*": ["*"],
            },
        },
    },
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));
const contracts = output.contracts[contractFileName];
fs.ensureDirSync(buildPath);

for (let contract in contracts) {
    if (contracts.hasOwnProperty(contract)) {
        fs.outputJsonSync(path.resolve(buildPath, `${contract}.json`), contracts[contract]);
    }
}
