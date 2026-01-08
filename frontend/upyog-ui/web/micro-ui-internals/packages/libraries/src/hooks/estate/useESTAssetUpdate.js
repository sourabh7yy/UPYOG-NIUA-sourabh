import { useMutation } from "react-query";
import { ESTService } from "../../services/elements/EST";

export const useESTAssetUpdate = () => {
  return useMutation((data) => {
    return ESTService.updateAsset(data);
  });
};
