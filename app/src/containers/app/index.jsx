import React, { Component } from 'react';

class App extends Component {
	render() {
		return (
			<div>
				<div>NIL-2</div>
				{this.props.children}
			</div>
		);
	}
}

export default App;