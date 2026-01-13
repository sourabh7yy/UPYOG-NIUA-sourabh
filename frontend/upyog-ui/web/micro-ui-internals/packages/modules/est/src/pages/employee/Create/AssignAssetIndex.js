import React, { useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useQueryClient } from "react-query";
import { Redirect, Route, Switch, useHistory, useLocation, useRouteMatch } from "react-router-dom";
import { Config } from "../../../config/Create/AssignAssetConfig";

/**
 * ESTAssignAssetCreate Component
 * --------------------------------------------------
 * This component manages the full multi-step
 * "Assign Asset" creation flow.
 *
 * Responsibilities:
 * - Controls step-based routing
 * - Stores form data in session storage
 * - Handles navigation between steps
 * - Renders check and acknowledgement pages
 */
const ESTAssignAssetCreate = ({ parentRoute }) => {
    // Access route state (data passed from previous page)
  const location = useLocation();
  const assetData = location.state?.assetData || {};
  // React Query client instance
  const queryClient = useQueryClient();
    // Route match information for relative paths
  const match = useRouteMatch();
    // Translation handler
  const { t } = useTranslation();
   // Current URL pathname
  const { pathname } = useLocation();
  
  // Navigation handler
  const history = useHistory();
  
  // State ID (used for tenant-specific operations)
  const stateId = Digit.ULBService.getStateId();
   // Final flattened configuration for all routes
  let config = [];
   /**
   * Session storage hook
   * Used to persist form data across steps and page refresh
   */
  const [params, setParams, clearParams] = Digit.Hooks.useSessionStorage("EST_ASSIGN_ASSETS", {});
   /**
   * Store asset data in session storage on first load
   * Prevents overwriting existing stored data
   */
  useEffect(() => {
    if (assetData && Object.keys(params).length === 0) {
      setParams({ assetData });
    }
  }, [assetData]);

 /**
   * Navigate to the next step in the workflow
    */

  const goNext = (skipStep, index, isAddMultiple, key) => {
    console.log("goNext called with:", { skipStep, index, isAddMultiple, key });
     // Identify current step from URL
    let currentPath = pathname.split("/").pop();
    let { nextStep = {} } = config.find((routeObj) => routeObj.route === currentPath);
    
    // Decide navigation method
    let redirectWithHistory = history.push;
    if (skipStep) {
      redirectWithHistory = history.replace;
    }

    // If this is the last step, go to check page
    if (nextStep === null) {
      return redirectWithHistory(`${match.path}/check`);
    }
        // Navigate to next configured step
    let nextPage = `${match.path}/${nextStep}`;
    redirectWithHistory(nextPage);
  };
  /**
   * Handle data submission from each step
   *
  */
  function handleSelect(key, data, skipStep, index, isAddMultiple = false) {
    console.log("handleSelect called with:", { key, data, skipStep, index, isAddMultiple });
    // Special handling for Documents step
    if (key === "Documents") {
      setParams({ ...params, assetData, [key]: data });
    } else {
      setParams({ ...params, [key]: data });
    }
       // Proceed to next step
    goNext(skipStep, index, isAddMultiple, key);
  }
// Placeholder skip handler (currently unused)
  const handleSkip = () => {};
  const handleMultiple = () => {};
 /**
   * Called after successful submission
   * Clears session storage and refreshes cached queries
   */
  const onSuccess = () => {
    clearParams();
    queryClient.invalidateQueries("EST_ASSIGN_ASSETS");
  };
 /**
   * Final submission handler
   * Redirects user to acknowledgement page
   */
  const estcreate = async () => {
    console.log("Final params before acknowlgement:", params);
  history.replace(`${match.path}/acknowledgement`);
};
  
  let commonFields = Config;
  commonFields.forEach((obj) => {
    config = config.concat(obj.body.filter((a) => !a.hideInCitizen));
  });
  
  config.indexRoute = "info";
  // Dynamically load check and acknowledgement components
  const ESTAssignAssetsCheckPage = Digit?.ComponentRegistryService?.getComponent("ESTAssignAssetsCheckPage");
  const ESTAllotmentAcknowledgement = Digit?.ComponentRegistryService?.getComponent("ESTAllotmentAcknowledgement");
   /**
   * Route rendering for the Assign Asset workflow
   */
  return (
    <Switch>
      {config.map((routeObj, index) => {
        const { component, texts, inputs, key } = routeObj;
        const Component = typeof component === "string" ? Digit.ComponentRegistryService.getComponent(component) : component;
        const user = Digit.UserService.getUser().info.type;
        return (
          <Route path={`${match.path}/${routeObj.route}`} key={index}>
           <Component config={{ texts, inputs, key }} onSelect={handleSelect} onSkip={handleSkip} t={t} formData={params} onAdd={handleMultiple} userType={user} />
          </Route>
        );
      })}

      {/* {console.log("params in create1111", params)} */}
      <Route path={`${match.path}/check`}>
       <ESTAssignAssetsCheckPage onSubmit={estcreate} value={params} />
      </Route>
      <Route path={`${match.path}/acknowledgement`}>
       <ESTAllotmentAcknowledgement data={params} onSuccess={onSuccess}/>
      </Route>
      <Route>
        <Redirect to={`${match.path}/${config.indexRoute}`} />  
      </Route>
      
    </Switch>
  );
};

export default ESTAssignAssetCreate;
