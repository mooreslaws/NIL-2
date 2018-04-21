import * as React from "react";
import * as ReactDOM from "react-dom";

import {Router, Route, browserHistory} from "react-router";


import App from "./containers/app/";
import CreateContract from './containers/createcontract/';

function Root() {
  return (
    <Router  history={browserHistory}>
      <Route component={App} >
      <Route path={"/"} component={CreateContract}/>
      </Route>
    </Router>
  );
}


ReactDOM.render(
  <Root />,
  document.getElementById("root")
);

