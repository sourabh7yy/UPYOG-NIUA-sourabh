import { useMutation } from "react-query";
import { ESTService } from "../../services/elements/EST";

// Hook to update EST Asset
// This hook uses react-query's useMutation to handle the update operation.

export const useESTAssetUpdate = () => {
  return useMutation((data) => {
    return ESTService.updateAsset(data);
  });
};
