import { AppContainer, PrivateRoute } from "@upyog/digit-ui-react-components";
import React from "react";
import { Switch } from "react-router-dom";
import MapView from "../../components/MapView";
import ServiceTypes from "../../components/ServiceTypes";
import ViewOnMapAsset from "../../components/ViewOnMapAsset";

// EmployeeApp component defining routes for employee users
const EmployeeApp = ({ path }) => {
  return (
    <Switch>
      <AppContainer>
        <PrivateRoute path={`${path}/servicetype`} component={ServiceTypes} />
        <PrivateRoute path={`${path}/mapview`} component={MapView} />
        <PrivateRoute path={`${path}/viewpolygon`} component={ViewOnMapAsset} />

      </AppContainer>
    </Switch>
  );
};

export default EmployeeApp;
