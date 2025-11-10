import { ASSETSearch } from "../../services/molecules/ASSET/Search";
import { useQuery } from "react-query";

const useAssetApplicationDetail = (t, tenantId, applicationNo, config = {}, userType, args) => {
  const stateTenantId = Digit.ULBService.getStateId();
  const defaultSelect = (data) => {
     let applicationDetails = data.applicationDetails;
    return {
      applicationData : data,
      applicationDetails
    }
  };

  
    const { data: cityResponseObject} =  Digit.Hooks.useEnabledMDMS(stateTenantId, "ASSETV2", [{ name: "AssetParentCategoryFields" }], {
      select: (data) => {
        
        const formattedData = data?.["ASSETV2"]?.["AssetParentCategoryFields"];
        return formattedData;
      },
    });
 
  
    let combinedData = cityResponseObject?cityResponseObject:[];


  return useQuery(
    ["APPLICATION_SEARCH", "ASSET_SEARCH", applicationNo, userType, combinedData,  args],
    () => ASSETSearch.applicationDetails(t, tenantId, applicationNo, userType, combinedData,  args),
    { select: defaultSelect, ...config }
 
  );
};

export default useAssetApplicationDetail;
