//Include Both Helper File with needed methods
import { getFirebaseBackend } from "../../../helpers/firebase_helper";
import {
  postFakeLogin,
  postJwtLogin,
} from "../../../helpers/fakebackend_helper";

import { loginSuccess, logoutUserSuccess, apiError, reset_login_flag } from './reducer';
import axios from "axios";

export const loginUser = (user : any, history : any) => async (dispatch : any) => {
  try {
    const apiUrl = process.env.REACT_APP_API_URL;
    console.log(apiUrl);
    
    const response = await axios.post(`${apiUrl}/admin/login`, {
      username: user.username,  // ✅ use username, not email
      password: user.password
    });

    const data = response;

    if (data) {
      sessionStorage.setItem("authUser", JSON.stringify(data));
      dispatch(loginSuccess(data));
      history('/dashboard');
    }

  } catch (error: any) {
    const errMsg = error.response?.data?.message || "Login failed";
    dispatch(apiError(errMsg));
  }
  // try {
  //   let response;
  //   if (process.env.REACT_APP_DEFAULTAUTH === "firebase") {
  //     let fireBaseBackend : any = getFirebaseBackend();
  //     response = fireBaseBackend.loginUser(
  //       user.email,
  //       user.password
  //     );
  //   } else if (process.env.REACT_APP_DEFAULTAUTH === "jwt") {
  //     response = postJwtLogin({
  //       email: user.email,
  //       password: user.password
  //     });

  //   } else if (process.env.REACT_APP_DEFAULTAUTH) {
  //     response = postFakeLogin({
  //       email: user.email,
  //       password: user.password,
  //     });
  //   }

  //   var data = await response;

  //   if (data) {
  //     sessionStorage.setItem("authUser", JSON.stringify(data));
  //     if (process.env.REACT_APP_DEFAULTAUTH === "fake") {
  //       var finallogin : any = JSON.stringify(data);
  //       finallogin = JSON.parse(finallogin)
  //       data = finallogin.data;
  //       if (finallogin.status === "success") {
  //         dispatch(loginSuccess(data));
  //         history('/dashboard')
  //       } 
  //       else {
  //         dispatch(apiError(finallogin));
  //       }
  //     } else {
  //       dispatch(loginSuccess(data));
  //       history('/dashboard')
  //     }
  //   }
  // } catch (error) {
  //   dispatch(apiError(error));
  // }
};

export const logoutUser = () => async (dispatch : any) => {
  try {
    sessionStorage.removeItem("authUser");
    let fireBaseBackend : any = getFirebaseBackend();
    if (process.env.REACT_APP_DEFAULTAUTH === "firebase") {
      const response = fireBaseBackend.logout;
      dispatch(logoutUserSuccess(response));
    } else {
      dispatch(logoutUserSuccess(true));
    }

  } catch (error) {
    dispatch(apiError(error));
  }
};

export const socialLogin = (type : any, history : any) => async (dispatch : any) => {
  try {
    let response;

    if (process.env.REACT_APP_DEFAULTAUTH === "firebase") {
      const fireBaseBackend : any = getFirebaseBackend();
      response = fireBaseBackend.socialLoginUser(type);
    }
    //  else {
      //   response = postSocialLogin(data);
      // }
      
      const socialdata = await response;
    if (socialdata) {
      sessionStorage.setItem("authUser", JSON.stringify(response));
      dispatch(loginSuccess(response));
      history('/dashboard')
    }

  } catch (error) {
    dispatch(apiError(error));
  }
};

export const resetLoginFlag = () => async (dispatch : any) => {
  try {
    const response = dispatch(reset_login_flag());
    return response;
  } catch (error) {
    dispatch(apiError(error));
  }
};