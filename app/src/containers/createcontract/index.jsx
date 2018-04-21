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

class CreateContract extends Component {
	constructor(props) {
      super(props)

      this.state = {
        balance: null
      }
    }
	componentDidMount() {
		getWeb3
			.then(({ web3 }) => {
				return web3.eth.getBalance('0xa3564D084fabf13e69eca6F2949D3328BF6468Ef')
			})
			.then((balance) => {
				this.setState({ balance})
			}) 
	}
	render() {
		const { balance } = this.state;
		return (
			<div>
				balance: {balance}
			</div>
		);
	}
}

export default CreateContract;