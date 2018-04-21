import React, { Component } from 'react';

class App extends Component {
	render() {
		return (
			<div>
				<h2 className='text-center'>NIL-2</h2>
				{this.props.children}
			</div>
		);
	}
}

export default App;