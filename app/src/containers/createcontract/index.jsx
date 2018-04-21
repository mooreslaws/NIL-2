import React, { Component } from 'react';


import Web3 from 'web3'

let getWeb3 = new Promise(function(resolve, reject) {
  // Wait for loading completion to avoid race conditions with web3 injection timing.
  window.addEventListener('load', function() {
    var results
    var web3 = window.web3

    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
    if (typeof web3 !== 'undefined') {
      // Use Mist/MetaMask's provider.
      web3 = new Web3(web3.currentProvider)

      results = {
        web3: web3
      }

      console.log('Injected web3 detected.');

      resolve(results)
    } else {
      // Fallback to localhost if no web3 injection. We've configured this to
      // use the development console's port by default.
      var provider = new Web3.providers.HttpProvider('https://kovan.infura.io/eKZdJzgmRo31DJI94iSO')

      web3 = new Web3(provider)

      results = {
        web3: web3
      }

      console.log('No web3 instance injected, using Local web3.');

      resolve(results)
    }
  })
})

const config = require('../../../../build/contracts/NIL2.json');
const NIL2Abi = config.abi;


// const getContract = () => {
//   return getWeb3
//       .then(results => {
//       const Contract = require('truffle-contract');
//       const contract = Contract(NIL2Abi);
//       contract.setProvider(results.web3.currentProvider);
//       results.web3.eth.defaultAccount = results.web3.eth.accounts[0];
//       return contract.deployed().then(contract => ({
//         contract,
//         web3: results.web3
//       }));
//     })
// }

// const web3 = new Web3(new Web3.providers.HttpProvider('https://kovan.infura.io/eKZdJzgmRo31DJI94iSO'));
// const contractAddress = config.networks['42'].address;

// //'0xfb5fbf7b14557561c20e04936664a198cb57f8b4';
// const contract = new web3.eth.Contract(NIL2Abi, contractAddress);


const ReactMarkdown = require('react-markdown')


let _contract;
let _web3;

const getContract = () => {
  return getWeb3
      .then(results => {
      const contract = require('truffle-contract');
      const registryContract = contract(config);
      registryContract.setProvider(results.web3.currentProvider);
      results.web3.eth.defaultAccount = results.web3.eth.accounts[0];
      return registryContract.deployed().then(contract => ({
        contract,
        web3: results.web3
      }));
    })
}

class CreateContract extends Component {
	constructor(props) {
      super(props)

      this.state = {
        params: [
          { name: 'BOSS', value: '' },
          { name: 'COUNTRYFROM', value: '' },
          { name: 'COUNTRYTO', value: '' }
        ],
        laoding: false
      }

      // this.get = this.get.bind(this);
      // this.set = this.set.bind(this);
      this.updateParametr = this.updateParametr.bind(this);
      this.loadData = this.loadData.bind(this);
    }
    
    // get() {
    //   _contract.getParameter('BOSS')
    //     .then(value => {
    //       debugger
    //     })
    // }

    // set() {
    //   _contract.addContractParameter('COUNTRYFROM', 'BRL', { from: '0xf2492533F7d89DBfEd69757156c4B746839E59E8' })
    //   .then(() => {
    //     debugger
    //   });
    // }

    loadData() {
      this.setState({
        laoding: true
      });
      const { params } = this.state;
      Promise.all(
        params.map(p => _contract.getParameter(p.name))
      ).then((data) => {
        const  _params = data.map((v, index) => {
          return {
            ...params[index],
            value: v
          }
        });

        this.setState({
          params: _params,
          laoding: false
        })
      })
    }
    updateParametr(name) {
      const value = this.refs[name].value;
      this.setState({
        laoding: true
      })
      _contract.addContractParameter(name, value, { from: '0xf2492533F7d89DBfEd69757156c4B746839E59E8' })
      .then(() => {
        this.setState({
          laoding: false
        })
      });
    }

	componentDidMount() {
      // getContract().then(({ contract, web3 }) => {

      // })

      getContract().then(({ contract, web3 }) => {
        _contract = contract;
        _web3 = web3;
        debugger
        // contract.addContractParameter('BOSS', 'BIG', { from: '0xa3564D084fabf13e69eca6F2949D3328BF6468Ef' }).then(() => {
        //   debugger
        // })
        this.loadData();
      })
		// getContract()
		// 	.then(({ web3 }) => {
		// 		return web3.eth.getBalance('0xa3564D084fabf13e69eca6F2949D3328BF6468Ef')
		// 	})
		// 	.then((balance) => {
		// 		this.setState({ balance})
		// 	})

//0xa3564D084fabf13e69eca6F2949D3328BF6468Ef
//0xf2492533F7d89DBfEd69757156c4B746839E59E8


// web3.eth.defaultAccount = web3.eth.accounts[0];
// debugger
//     getContract().then(({ contract }) => {
//       contract.addContractParameter('BOSS', 'BIG', { from: web3.eth.accounts[0] }).then(() => {
//         debugger
//       })
//     })
  
    // contract.methods.addGood('BOSS', 'Big', '213', 10).send({
    //   from: '0xf2492533F7d89DBfEd69757156c4B746839E59E8'
    // })
    // contract.methods.getContractName().call().then(data => {
    //   debugger
    // })
	}
	render() {
		const { params, laoding } = this.state;

    const rows = params.map(p => (
      <tr key={p.name}>
        <td>{p.name}</td>
        <td><input ref={p.name} defaultValue={p.value}/></td>
        <td><button onClick={() => this.updateParametr(p.name)}>update</button></td>
      </tr>
    ))

const input = '# This is a header\n\nAnd this is a paragraph'


		return (
			<div>
        <div>
           <ReactMarkdown source={input} />
        </div>
        {!laoding && <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Value</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {rows}
          </tbody>
        </table>}
        {laoding && <div>loading...</div>}
        {/*<button onClick={this.get}>get</button>
        <button onClick={this.set}>set</button>*/}
			</div>
		);
	}
}

export default CreateContract;