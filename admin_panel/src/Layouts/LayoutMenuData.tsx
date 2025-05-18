import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

// Import Icons
import FeatherIcon from "feather-icons-react";

const Navdata = () => {
  const history = useNavigate();
  // state data
  const [isDashboard, setIsDashboard] = useState<boolean>(false);
  const [isApps, setIsApps] = useState<boolean>(false);
  const [isAuth, setIsAuth] = useState<boolean>(false);
  const [isPages, setIsPages] = useState<boolean>(false);
  const [isBaseUi, setIsBaseUi] = useState<boolean>(false);
  const [isAdvanceUi, setIsAdvanceUi] = useState<boolean>(false);
  const [isForms, setIsForms] = useState<boolean>(false);
  const [isTables, setIsTables] = useState<boolean>(false);
  const [isCharts, setIsCharts] = useState<boolean>(false);
  const [isIcons, setIsIcons] = useState<boolean>(false);
  const [isMaps, setIsMaps] = useState<boolean>(false);
  const [isMultiLevel, setIsMultiLevel] = useState<boolean>(false);

  const [iscurrentState, setIscurrentState] = useState("Dashboard");

  function updateIconSidebar(e: any) {
    if (e && e.target && e.target.getAttribute("sub-items")) {
      const ul: any = document.getElementById("two-column-menu");
      const iconItems = ul.querySelectorAll(".nav-icon.active");
      let activeIconItems = [...iconItems];
      activeIconItems.forEach((item) => {
        item.classList.remove("active");
        var id = item.getAttribute("sub-items");
        const getID = document.getElementById(id) as HTMLElement;
        if (getID) getID.classList.remove("show");
      });
    }
  }

  useEffect(() => {
    document.body.classList.remove("twocolumn-panel");
    if (iscurrentState !== "Dashboard") {
      setIsDashboard(false);
    }
    if (iscurrentState !== "Apps") {
      setIsApps(false);
    }
    if (iscurrentState !== "Auth") {
      setIsAuth(false);
    }
    if (iscurrentState !== "Pages") {
      setIsPages(false);
    }
    if (iscurrentState !== "BaseUi") {
      setIsBaseUi(false);
    }
    if (iscurrentState !== "AdvanceUi") {
      setIsAdvanceUi(false);
    }

    if (iscurrentState !== "Forms") {
      setIsForms(false);
    }
    if (iscurrentState !== "Tables") {
      setIsTables(false);
    }
    if (iscurrentState !== "Charts") {
      setIsCharts(false);
    }
    if (iscurrentState !== "Icons") {
      setIsIcons(false);
    }
    if (iscurrentState !== "Maps") {
      setIsMaps(false);
    }
    if (iscurrentState !== "MuliLevel") {
      setIsMultiLevel(false);
    }
    if (iscurrentState === "Widgets") {
      history("/widgets");
      document.body.classList.add("twocolumn-panel");
    }

  }, [history, iscurrentState]);

  const menuItems: any = [
    {
      label: "Menu",
      isHeader: true,
    },
    {
      id: "dashboard",
      label: "Dashboard",
      icon: <FeatherIcon icon="home" className="icon-dual" />,
      link: "/#",
      stateVariables: isDashboard,
      click: function (e: any) {
        e.preventDefault();
        setIsDashboard(!isDashboard);
        setIscurrentState("Dashboard");
        updateIconSidebar(e);
      },
    },
    {
      id: "users",
      label: "Users",
      icon: <FeatherIcon icon="home" className="icon-dual" />,
      link: "/users",
      stateVariables: isDashboard,
      click: function (e: any) {
        e.preventDefault();
        setIscurrentState("Users");
        history("/users"); // Navigate to /users
        updateIconSidebar(e);
      },
    },
    {
      id: "chat",
      label: "Chat",
      icon: <FeatherIcon icon="home" className="icon-dual" />,
      link: "/chat",
      stateVariables: isDashboard,
      click: function (e: any) {
        e.preventDefault();
        setIscurrentState("Chat");
        history("/chat"); // Navigate to /users
        updateIconSidebar(e);
      },
    },

  ];

  return <React.Fragment>{menuItems}</React.Fragment>;
};
export default Navdata;
